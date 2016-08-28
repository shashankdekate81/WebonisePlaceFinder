//
//  PlaceDataProvider.swift
//  PlaceFinder
//
//  Created by Anupam Pahari on 27/08/16.
//  Copyright © 2016 Northzone. All rights reserved.
//

import Foundation
import GooglePlaces


class PlaceDataProvider {
    
    private func makePlaceRequestQuery(placeName:String)->NSURL{
        
        var escapedString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(placeName)&sensor=false"
            
        escapedString = escapedString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        print(escapedString)
    
        let url = NSURL(string:escapedString )
        
        print(url)
        
        return url!
    }
    
    func fetchThePlaceDataFromServer(placeName:String){
        
        let placeRequestUrl = makePlaceRequestQuery(placeName)
        
        let placeInfoRequestSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        var dataTask: NSURLSessionDataTask?
        
        dataTask = placeInfoRequestSession.dataTaskWithURL(placeRequestUrl) {
            data, response, error in
            
            let httpResponse = response as? NSHTTPURLResponse
            
            if (error == nil && data != nil && httpResponse?.statusCode == 200){
                PlaceModelWrapper.sharedInstance.modelWrapper_didRecieveSucessFullResponse(data!)
            }else{
                PlaceModelWrapper.sharedInstance.modelWrapper_didRecieveErrorInResponse(error!)
            }
        }
        
        dataTask?.resume()
    }
    
    func getTheCurrentLocation(){
    
        GMSPlacesClient.sharedClient().currentPlaceWithCallback({
                        (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
        
        if let error = error {
            print("Pick Place error: \(error.localizedDescription)")
            return
        }
            
        if let placeLikelihoodList = placeLikelihoodList {
            let place = placeLikelihoodList.likelihoods.first?.place
            if let place = place {
                let placeCoordinate = CLLocationCoordinate2D(latitude:place.coordinate.latitude, longitude:place.coordinate.longitude)
                PlaceModelWrapper.sharedInstance.modelWrapper_didGetTheCurrentLocation(placeCoordinate)
            }
            }
        })
    
    }
    
    func fetchThePlacePhotosFromServer(placeID:String){
        
        GMSPlacesClient.sharedClient().lookUpPhotosForPlaceID(placeID) { (photos, error) -> Void in
            
            print(photos?.results.count)
            
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.description)")
            } else {
                self.loadImageForMetadata((photos?.results)!)
                print(photos?.results.first?.attributions!)
            }
        }
    }
    
    private func loadImageForMetadata(photosMetadata: [GMSPlacePhotoMetadata]) {
        
        
        
        for photoMetadata in photosMetadata{
            GMSPlacesClient.sharedClient().loadPlacePhoto(photoMetadata,constrainedToSize:CGSizeMake(100, 100),scale:10.0)
                {
                    
                    (photo, error) -> Void in
                    
                    print(photoMetadata.attributions)

                    if let error = error {
                                        // TODO: handle the error
                        print("Error: \(error.description)")
                    } else {
                        
                        PlaceModelWrapper.sharedInstance.modelWrapper_didRecievePhotoForLocation([(photoMetadata.attributions?.string)! : photo!])
                        
                    }
                }
        }
    }

}