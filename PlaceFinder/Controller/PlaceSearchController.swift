//
//  ViewController.swift
//  PlaceFinder
//
//  Created by Anupam Pahari on 16/08/16.
//  Copyright © 2016 Northzone. All rights reserved.
//

import UIKit
import GooglePlaces

class PlaceSearchController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet var searchtableView: UITableView!
    
    @IBOutlet var searchPlaceBar: UISearchBar!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var arrOfHistory:[String] = []
    var arrAutoComplete:[String] = []
    var placeInfoObj:PlaceInfo?
    
    let locationManager = CLLocationManager()
    var currentCoordinate:CLLocationCoordinate2D? = nil

    var searchForDataBase:Bool = false
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        searchPlaceBar.delegate = self
        searchtableView.hidden = true
        
        PlaceModelWrapper.sharedInstance.networkCallDelegate = self
        PlaceModelWrapper.sharedInstance.dbFetchDelegate = self
        
        self.searchtableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        searchForDataBase = false
        activityIndicator.hidden = true
        searchPlaceBar.userInteractionEnabled = true
        
        searchtableView.layer.borderWidth = 1.0
        searchtableView.layer.borderColor = UIColor.grayColor().CGColor
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        PlaceModelWrapper.sharedInstance.networkCallDelegate = nil
        searchForDataBase = false
    }
    
    
    private func pushViewController(){
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.searchPlaceBar.text = ""
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let objSomeViewController = storyBoard.instantiateViewControllerWithIdentifier("googleMap") as! MapViewController
            
            objSomeViewController.placeInfoObj = self.placeInfoObj
            objSomeViewController.currentCoordinate = self.currentCoordinate
            
            self.navigationController?.pushViewController(objSomeViewController, animated: true)
            
            }
        )
    }
}

extension PlaceSearchController{
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations.first?.coordinate.latitude,locations.first?.coordinate.longitude)
        
        currentCoordinate = CLLocationCoordinate2D(latitude: (locations.first?.coordinate.latitude)!, longitude: (locations.first?.coordinate.longitude)!)
        
        if locations.first != nil {
            locationManager.stopUpdatingLocation()
        }
    }
}

extension PlaceSearchController:UISearchBarDelegate{

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("search bar Button clicked")
        
        searchBar.resignFirstResponder()
        searchBar.userInteractionEnabled = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    
        PlaceModelWrapper.sharedInstance.modelWrapper_FetchCurrentPlaceInfoFromDataBase(searchBar.text!)

    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if(self.arrOfHistory.count>0){
        
        }else{
            PlaceModelWrapper.sharedInstance.modelWrapper_fetchAllPlaceInfoFromDataBase()
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if(searchText.isEmpty){
            arrAutoComplete.removeAll()
            searchtableView.hidden = true
        }else{
            
            print(arrOfHistory)
            
            let filterString = arrOfHistory.filter({(item: String) -> Bool in
                let stringMatch = item.lowercaseString.rangeOfString(searchText.lowercaseString)
                if(stringMatch != nil){
                    return String(stringMatch!.startIndex) != "0" ? false : true
                }
                return false
            })
            
            print(filterString)
            
            arrAutoComplete.removeAll()
            if(filterString.count > 0){
                arrAutoComplete = filterString
                searchtableView.hidden = false
                searchtableView.reloadData()
            }else{
                searchtableView.hidden = true
                searchtableView.reloadData()
            }
        }
        
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
}

extension PlaceSearchController:UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAutoComplete.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = arrAutoComplete[indexPath.row]
        
        return cell
    }
    
}

extension PlaceSearchController:UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        self.searchPlaceBar.text = cell?.textLabel?.text
        
        tableView.hidden = true
        
        searchForDataBase = true
        
    }

}

extension PlaceSearchController:modelWrapperNetworkCallResponse{
    
    func didRecieveSucessFullResponse(placeInfo:PlaceInfo){
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            placeInfoObj = placeInfo
            pushViewController()
    }
    
    func didRecieveErrorInResponse(error:NSError){
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        searchPlaceBar.userInteractionEnabled = true
        
        let alertController = UIAlertController(title: Alert, message:Invalid_Search, preferredStyle: .Alert)
        let okAction = UIAlertAction(title:OK_, style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        
        
        alertController.addAction(okAction)
        
        
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension PlaceSearchController:modelWrapperDBFetch{
    
    func didSucessFetchAllPlaceInfoFromDataBase(arrOfHistory:[String]){
        self.arrOfHistory = arrOfHistory
    }
    
    func didSucessFetchCurrentPlaceInfoFromDataBase(placeInfo:PlaceInfo){
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        searchPlaceBar.userInteractionEnabled = true
        placeInfoObj = placeInfo
        pushViewController()
    }


}
