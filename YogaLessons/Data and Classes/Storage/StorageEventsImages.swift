//
//  StorageEventsImages.swift
//  YogaLessons
//
//  Created by Eran karaso on 20/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseAuth
import FirebaseStorage
import SDWebImage

extension StorageManager{
    
    func save(image img:UIImage,for event:Event,completion:DSTaskListener? = nil) {
        
        guard let imgData = img.jpegData(compressionQuality: 0.0) else {return }
        
        // Create a reference to the file you want to upload
        let eventImgRef = storage.reference(withPath: EVENTS_IMAGES).child(event.id)
        
        eventImgRef.putData(imgData,metadata: nil){(metadata, error) in
            print("event image uploaded to storage")
            // Fetch the download URL
            eventImgRef.downloadURL { url, error in
                if let error = error {
                    // Handle any errors
                    completion?(error)
                } else {
                    // Get the download URL
                    
                    guard let path = url?.absoluteString else{
                        completion?(nil)//some err of url
                        return}
                    event.imageUrl = path
                    DataSource.shared.saveEventImgToDB(from: path, eventID: event.id,completion: completion)
                }
            }
        }
    }
    
    func setImage(of event:Event, imgView:UIImageView){
        
        if let url = event.imageUrl {
            setImage(withUrl: URL(string: url), imgView: imgView,placeHolderImg: #imageLiteral(resourceName: "imgPlaceholder"))
        }else{
            imgView.image = nil
        }
    }
    
    func removeImage(forEvent event:Event,updateOnDB:Bool = true,completion:DSTaskListener? = nil) {
        guard event.imageUrl != nil else{return}
        
        // remove a reference to the file you want to upload
        storage.reference(withPath: EVENTS_IMAGES)
            .child(event.id).delete { error in
                if let errorDesc = error?.localizedDescription {
                    // Uh-oh, an error occurred!
                    print(errorDesc)
                } else {
                    // File deleted successfully
                    event.imageUrl = nil
                    print("Image deleted from storage")
                    if updateOnDB{
                    DataSource.shared.removeEventImageFromDB(event.id,completion:completion )
                    }
                }
        }
    }
}
