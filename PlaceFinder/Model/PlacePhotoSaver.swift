//
//  PlacePhotoSaver.swift
//  PlaceFinder
//
//  Created by Anupam Pahari on 28/08/16.
//  Copyright © 2016 Northzone. All rights reserved.
//

import Foundation
import UIKit

class PlacePhotoSaver{
    
    private func getDocumentDirectoryPath()->String{
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return path

    }
    
    func saveImagesToDocumentDirectory(selectedImage:[Int:[String:UIImage]]){
        let documentDirectoryPathURL  = NSURL(fileURLWithPath: getDocumentDirectoryPath())
        
        for (_,placeDic) in  selectedImage{
            
            let photoName = Array(placeDic.keys).count == 1 ? Array(placeDic.keys)[0] : Default_
            let filePath = documentDirectoryPathURL.URLByAppendingPathComponent((photoName + ".png"))
            if let image = placeDic[photoName]{
                writeImageToPath(image, filePath:filePath)
            }
        }
        
        PlaceModelWrapper.sharedInstance.modelWrapper_didPhotoSaveSuccessfully()
    }
    
    private func writeImageToPath(placeImage:UIImage,filePath:NSURL)->Bool{
        let pngData = UIImagePNGRepresentation(placeImage)
        do{
            try pngData?.writeToURL(filePath, options: NSDataWritingOptions.AtomicWrite)
        }catch {
        
        }
        
        return true
    }
}
