//
//  modelWrapper.swift
//  PlaceFinder
//
//  Created by Anupam Pahari on 27/08/16.
//  Copyright © 2016 Northzone. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


@objc protocol modelWrapperNetworkCallResponse {
    optional func didRecieveSucessFullResponse(placeInfo:PlaceInfo)
    optional func didRecieveErrorInResponse(error:NSError)
    optional func didReceiveCurrentLocation(currentCoordinate:CLLocationCoordinate2D)
    optional func didRecievePhotoForLocation(photoDic:[String:UIImage])
}

protocol modelWrapperDBFetch {
    func didSucessFetchAllPlaceInfoFromDataBase(arrOfHistory:[String])
    func didSucessFetchCurrentPlaceInfoFromDataBase(placeInfo:PlaceInfo)
}

protocol modelWrapperPhotoSave {
    func didPhotoSaveSuccessfully()
}

class PlaceModelWrapper{
    
    static let sharedInstance:PlaceModelWrapper = PlaceModelWrapper()
    
    var networkCallDelegate:modelWrapperNetworkCallResponse?
    var dbFetchDelegate:modelWrapperDBFetch?
    var photoSaveDelegate:modelWrapperPhotoSave?
    
    private let placeDataProviderObj:PlaceDataProvider = PlaceDataProvider()
    private let placeDataParserObj:PlaceDataParser = PlaceDataParser()
    private let placeDataBaseObj:PlaceDataBase = PlaceDataBase()
    private let placePhotoSaverObj:PlacePhotoSaver = PlacePhotoSaver()
    
    private init(){}
    
    func modelWrapper_FetchThePlaceDataFromServer(placeName:String){
        placeDataProviderObj.fetchThePlaceDataFromServer(placeName)
    }
    
    func modelWrapper_didRecieveSucessFullResponse(placeData:NSData){
        placeDataParserObj.parseThePlaceData(placeData)
    }
    
    func modelWrapper_didRecieveErrorInResponse(error:NSError){
        networkCallDelegate?.didRecieveErrorInResponse!(error)
    }
    
    func modelWrapper_didParseSucessfull(placeInfo:PlaceInfo){
        
        placeDataBaseObj.insertPlaceInfoInDataBase(placeInfo)
    }
    
    func modelWrapper_didInsertPlaceInfoInDataBase(placeInfo:PlaceInfo){
        networkCallDelegate?.didRecieveSucessFullResponse!(placeInfo)
    }
    
    func modelWrapper_didFailInsertPlaceInfoInDataBase(error:NSError){
        networkCallDelegate?.didRecieveErrorInResponse!(error)
    }
    
    func modelWrapper_didParserFailed(error:NSError){
        networkCallDelegate?.didRecieveErrorInResponse!(error)
    }
    
    func modelWrapper_fetchAllPlaceInfoFromDataBase(){
        placeDataBaseObj.fetchAllPlaceInfoFromDataBase()
    }
    
    func modelWrapper_didfetchAllPlaceInfoFromDataBase(arrPlace:[String]){
        dbFetchDelegate?.didSucessFetchAllPlaceInfoFromDataBase(arrPlace)
    }
    
    func modelWrapper_getTheCurrentLocation(){
        placeDataProviderObj.getTheCurrentLocation()
    }
    
    func modelWrapper_didGetTheCurrentLocation(currentCoordinate:CLLocationCoordinate2D){
        networkCallDelegate?.didReceiveCurrentLocation!(currentCoordinate)
    }
    
    func modelWrapper_fetchThePlacePhotosFromServer(placeID:String){
        placeDataProviderObj.fetchThePlacePhotosFromServer(placeID)
    }
    
    func modelWrapper_didRecievePhotoForLocation(photoDic:[String:UIImage]){
        networkCallDelegate?.didRecievePhotoForLocation!(photoDic)
    }
    
    func modelWrapper_FetchCurrentPlaceInfoFromDataBase(placeName:String){
        placeDataBaseObj.fetchCurrentPlaceInfoFromDataBase(placeName)
    }
    
    func modelWrapper_didFetchCurrentPlaceInfoFromDataBase(placeInfo:PlaceInfo){
        dbFetchDelegate?.didSucessFetchCurrentPlaceInfoFromDataBase(placeInfo)
    }
    
    func modelWrapper_didCurrentPlaceIsNotPresent(placeName:String){
        modelWrapper_FetchThePlaceDataFromServer(placeName)
    }
    
    func modelWrapper_saveImagesToDocumentDirectory(selectedImage:[Int:[String:UIImage]]){
        placePhotoSaverObj.saveImagesToDocumentDirectory(selectedImage)
    }
    
    func modelWrapper_didPhotoSaveSuccessfully(){
        photoSaveDelegate?.didPhotoSaveSuccessfully()
    }
    
}