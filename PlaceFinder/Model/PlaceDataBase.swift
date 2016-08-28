//
//  PlaceDataBase.swift
//  PlaceFinder
//
//  Created by Anupam Pahari on 27/08/16.
//  Copyright © 2016 Northzone. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CoreLocation

class PlaceDataBase {
    
    private func getManagedObjectContext()->NSManagedObjectContext{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        return managedContext
    }
    
    private func sameValueAlreadyPresent(placeInfo:PlaceInfo)->Bool{
        let managedContext = getManagedObjectContext()
        let fetchRequest = NSFetchRequest(entityName: placeInfo_Entity)
        fetchRequest.predicate = NSPredicate(format:query_For_Name ,placeInfo.placeName)
        fetchRequest.resultType = .CountResultType
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [NSNumber]
            let count = results.first!.integerValue
            if count != 0 {
                return false
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    

        return true
    }
    
    func insertPlaceInfoInDataBase(placeInfo:PlaceInfo){
        
        if(self.sameValueAlreadyPresent(placeInfo)){
        
        let managedContext = getManagedObjectContext()
        let entity = NSEntityDescription.entityForName(placeInfo_Entity, inManagedObjectContext:managedContext)
        let placeInfoNSObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        placeInfoNSObj.setValue(placeInfo.placeName, forKey: place_Name)
        placeInfoNSObj.setValue(placeInfo.placeAdress, forKey: place_Adress)
        placeInfoNSObj.setValue(placeInfo.placeID, forKey: place_ID)
        placeInfoNSObj.setValue(placeInfo.placeCoordinate?.latitude, forKey: place_Lat)
        placeInfoNSObj.setValue(placeInfo.placeCoordinate?.longitude, forKey: place_Log)
    
        
        do {
            try managedContext.save()
            PlaceModelWrapper.sharedInstance.modelWrapper_didInsertPlaceInfoInDataBase(placeInfo)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            PlaceModelWrapper.sharedInstance.modelWrapper_didFailInsertPlaceInfoInDataBase(error)
        }
        }
    }
    
    func fetchAllPlaceInfoFromDataBase(){
        
         let managedContext = getManagedObjectContext()
        
        let fetchRequest = NSFetchRequest(entityName: placeInfo_Entity)
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.propertiesToFetch = [place_Name]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            var arrPlace :[String] = []
            for result in results{
                arrPlace.append(result.valueForKey(place_Name) as! String)
            }
            
            PlaceModelWrapper.sharedInstance.modelWrapper_didfetchAllPlaceInfoFromDataBase(arrPlace)
           
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func fetchCurrentPlaceInfoFromDataBase(placeName:String){
        
        let placeInfo:PlaceInfo = PlaceInfo()
        
        let managedContext = getManagedObjectContext()
        let fetchRequest = NSFetchRequest(entityName: placeInfo_Entity)
        fetchRequest.predicate = NSPredicate(format:query_For_Name,placeName)
        fetchRequest.resultType = .ManagedObjectResultType
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            if(results.count == 1){
                
                placeInfo.placeName = results[0].valueForKey(place_Name) as! String
                placeInfo.placeAdress = results[0].valueForKey(place_Adress) as! String
                placeInfo.placeID = results[0].valueForKey(place_ID) as! String
                let lat = results[0].valueForKey(place_Lat) as! CLLocationDegrees
                let lon = results[0].valueForKey(place_Log) as! CLLocationDegrees
                placeInfo.placeCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                PlaceModelWrapper.sharedInstance.modelWrapper_didFetchCurrentPlaceInfoFromDataBase(placeInfo)
            }else{
                PlaceModelWrapper.sharedInstance.modelWrapper_didCurrentPlaceIsNotPresent(placeName)
            }
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}




