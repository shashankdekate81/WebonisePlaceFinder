//
//  MapViewController.swift
//  PlaceFinder
//
//  Created by Anupam Pahari on 27/08/16.
//  Copyright © 2016 Northzone. All rights reserved.
//

import UIKit
import GoogleMaps



class MapViewController: UIViewController {
    
    var currentCoordinate:CLLocationCoordinate2D?
    var arrPlacePhotoDic:[[String:UIImage]] = [[:]]
    var placeInfoObj:PlaceInfo?
    var selectedImage:[Int:[String:UIImage]] = [:]
    var googleMapView:GMSMapView?

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var downloadImageBtn: UIButton!
    @IBOutlet var placePhotoCollection: UICollectionView!
    
    @IBAction func downloadImageBtnAction(sender: AnyObject) {
        self.view.userInteractionEnabled = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MapViewController.SaveImage), userInfo: nil, repeats: false)
    }
    
    func SaveImage(){
        PlaceModelWrapper.sharedInstance.modelWrapper_saveImagesToDocumentDirectory(selectedImage)
    }
    
    override func viewDidLoad() {
        
        let position = currentCoordinate
        let marker = GMSMarker(position: position!)
        
        let camera  = GMSCameraPosition.cameraWithLatitude((currentCoordinate?.latitude)!, longitude: (currentCoordinate?.longitude)!, zoom: 15)
        self.mapView!.camera = camera
        
        marker.title = current_Location
        marker.map = self.mapView
        PlaceModelWrapper.sharedInstance.photoSaveDelegate = self
        activityIndicator.hidden = true
    
    }
    
    override func viewWillAppear(animated: Bool) {
        PlaceModelWrapper.sharedInstance.networkCallDelegate = self
        placePhotoCollection.backgroundColor = UIColor.whiteColor()
        PlaceModelWrapper.sharedInstance.modelWrapper_fetchThePlacePhotosFromServer((placeInfoObj?.placeID)!)
        downloadImageBtn.enabled = false
        downloadImageBtn.layer.borderWidth = 1.0
        downloadImageBtn.layer.borderColor = UIColor.purpleColor().CGColor
        placePhotoCollection.layer.borderWidth = 1.0
        placePhotoCollection.layer.borderColor = UIColor.purpleColor().CGColor
    }
    
    override func viewWillDisappear(animated: Bool) {
        PlaceModelWrapper.sharedInstance.networkCallDelegate = nil
    }

}

extension MapViewController:modelWrapperNetworkCallResponse{

    func didReceiveCurrentLocation(currentCoordinate:CLLocationCoordinate2D){
        self.currentCoordinate = currentCoordinate

    }
    
    func didRecievePhotoForLocation(photoDic:[String:UIImage]){
        arrPlacePhotoDic.append(photoDic)
        placePhotoCollection.reloadData()
    }

}

extension MapViewController:UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrPlacePhotoDic.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photo_Cell, forIndexPath: indexPath)
        
        let uiView = cell.viewWithTag(0)
        
        let imageView = UIImageView(frame: CGRectMake(3, 3, 100, 100))
        
        imageView.image = Array(arrPlacePhotoDic[indexPath.item].keys).count == 1 ? arrPlacePhotoDic[indexPath.item][Array(arrPlacePhotoDic[indexPath.item].keys)[0]] : nil
        
        uiView!.addSubview(imageView)
        
        
        if(selectedImage.count>0){
            if(selectedImage[indexPath.item] == nil){
                cell.backgroundColor = UIColor.whiteColor()
            }else{
                cell.backgroundColor = UIColor.purpleColor()
            }
        }else{
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        cell.layer.borderColor = UIColor.purpleColor().CGColor
        cell.layer.borderWidth = 1.0
        

        return  cell
    }
}

extension MapViewController:UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        if(selectedImage[indexPath.item] == nil){
            selectedImage[indexPath.item] = arrPlacePhotoDic[indexPath.item]
            cell?.backgroundColor = UIColor.purpleColor()
        }else{
            selectedImage[indexPath.item] = nil
            cell?.backgroundColor = UIColor.whiteColor()
        }
        
        if selectedImage.count>0 {

            downloadImageBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
            downloadImageBtn.enabled = true
            
        }else{
            downloadImageBtn.setTitleColor(UIColor.grayColor(), forState: .Disabled)
            downloadImageBtn.enabled = false

        }
}
    
}

extension MapViewController:modelWrapperPhotoSave{

    func didPhotoSaveSuccessfully() {
        self.view.userInteractionEnabled = true
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        selectedImage.removeAll(keepCapacity: true)
        placePhotoCollection.reloadData()
    }

}
