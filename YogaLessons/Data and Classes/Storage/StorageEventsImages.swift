//
//  StorageEventsImages.swift
//  YogaLessons
//
//  Created by Eran karaso on 20/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

extension StorageManager{
    
    func save(image img:UIImage,for event:Event,completion:((Error?)->Void)? = nil) {
        
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
                    self.saveEventImgToDB(from: path, eventID: event.id)
                    completion?(nil)
                }
            }
        }
    }
    
   
    
    fileprivate func getEventImgRef(_ eventID: String) -> DatabaseReference {
        
        let path = [DataSource.TableNames.events.rawValue,
                    eventID,
                    Event.Keys.imageUrl].joined(separator: "/")
        
        return Database.database().reference().child(path)
    }
    
    private func saveEventImgToDB(from path:String,eventID:String){
        //save to DB
        getEventImgRef(eventID).setValue(path){(error,childRef) in
                
                if let err = error{
                    ErrorAlert.show(message: err.localizedDescription)
                    return
                }
                print("Image successfully updated in DB")
        }
    }
    
    func setImage(of event:Event, imgView:UIImageView){
        
        if let url = event.imageUrl {
            setImage(withUrl: url, imgView: imgView,placeHolderImg: #imageLiteral(resourceName: "imgPlaceholder"))
        }
    }
    
    func removeImage(forEvent event:Event,updateOnDB:Bool = true) {
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
                        self.removeEventImageFromDB(event.id)
                    }
                }
        }
    }
    
    private func removeEventImageFromDB(_ eventId:String){
        
        //upadte in DB
        getEventImgRef(eventId).removeValue(){(error,childRef) in
                
                if let err = error{
                    ErrorAlert.show(message: err.localizedDescription)
                    return
                }
                
                print("Image successfully updated in DB")
        }
    }
}
