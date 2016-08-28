//
//  PlaceDataParser.swift
//  PlaceFinder
//
//  Created by Anupam Pahari on 27/08/16.
//  Copyright © 2016 Northzone. All rights reserved.
//

import Foundation
import CoreLocation

class PlaceDataParser {

    func parseThePlaceData(data:NSData){
        
        let placeInfoObj:PlaceInfo = PlaceInfo()
        
        do{
            
            let dic = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as!  NSDictionary
            
            if(dic[status_] as! String == ZERO_RESULTS){
                
                let error :NSError = NSError(domain:domain_Name, code: 203, userInfo: nil)
                PlaceModelWrapper.sharedInstance.modelWrapper_didRecieveErrorInResponse(error)
            }else if(dic[status_] as! String == OK_){
            
                if let arrPlaceName = dic[results_]?.valueForKey(address_components){
                    if(arrPlaceName.count>0){
                        if let placeName = arrPlaceName.objectAtIndex(0).objectAtIndex(0).valueForKey(long_name){
                            placeInfoObj.placeName = placeName as! String
                        }
                    }
                }
                
                if let address = dic[results_]?.valueForKey(formatted_address)?.objectAtIndex(0){
                    placeInfoObj.placeAdress = address as! String
                }
                
                if let placeID = dic[results_]?.valueForKey(place_id)?.objectAtIndex(0){
                    placeInfoObj.placeID = placeID as! String
                }
                
                let lat = dic[results_]?.valueForKey(geometry_)?.valueForKey(location_)?.valueForKey(lat_)?.objectAtIndex(0) as! Double
                let lon = dic[results_]?.valueForKey(geometry_)?.valueForKey(location_)?.valueForKey(lng_)?.objectAtIndex(0) as! Double
                
                placeInfoObj.placeCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                PlaceModelWrapper.sharedInstance.modelWrapper_didParseSucessfull(placeInfoObj)
                
            }
        }catch {
            print("Error")
        }
        
    }
    
}