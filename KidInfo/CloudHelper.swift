//
//  CloudHelper.swift
//  KidInfo
//
//  Created by i814935 on 12/11/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation
import UIKit

protocol CloudHelperDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
}

class CloudHelper{
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    var delegate: CloudHelperDelegate?
    
    class func sharedInstance() -> CloudHelper{
        return cloudHelper
    }
    
    init(){
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    // get kids from CloudKit Private DB
    func getKids(){
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "dob", ascending: false)
        
        let query = CKQuery(recordType: "Kid",
                            predicate:  predicate)
        query.sortDescriptors = [sort]
        
        self.privateDB.perform(query, inZoneWith: nil, completionHandler: {results, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.errorUpdating(error: error! as NSError)
                    return
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.modelUpdated()
                    return
                }
            }
        })
    }
    
    // Save kid to CloudKit private DB
    func saveKidInfo(kid: Kid){
        let predicate = NSPredicate(format: "id = %@", argumentArray: [kid.id!])
        let query = CKQuery(recordType: "Kid", predicate: predicate)
        
        // make request to see if Kid exists
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(records, error) -> Void in
            if(error == nil){
                if(records?.count == 0){
                    // save new kid
                    self.saveUpdateKidInfo(kid: kid);
                } else {
                    // update kid info
                    self.saveUpdateKidInfo(kid: kid, recordToUpdate: records!.first!);
                }
                
                // get list of kids
                self.getKids();
            } else {
                NSLog(error!.localizedDescription)
            }
        })
    }
    
    // get the saved location of avatar for kid
    private func getAvatarURL(kid: Kid) -> NSURL{
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let imagePath = directoryPath.strings(byAppendingPaths: ["tempImg.jpg"])
        let imageData:NSData = kid.avatar! as NSData;
        imageData.write(toFile: imagePath[0], atomically: true)
        let photoURL = NSURL(fileURLWithPath: imagePath[0])
        print(photoURL)
        return photoURL;
    }
    
    // save/update kid info
    private func saveUpdateKidInfo(kid: Kid, recordToUpdate: CKRecord? = nil){
        var kidRecord: CKRecord;
        
        // check to see if updating existing record
        if(recordToUpdate != nil){
            // Update existing Kid Info
            kidRecord = recordToUpdate!
        } else {
            // save new kid info
            kidRecord = CKRecord(recordType: "Kid")
        }
        
        // check if avatar set for kid
        if(kid.avatar != nil){
            // get avatar asset info
            let imageURL = getAvatarURL(kid: kid)
            let imageAsset = CKAsset(fileURL: imageURL as URL)
            kidRecord.setValue(imageAsset, forKey: "avatar")
        }
        
        // set values
        kidRecord.setValue(kid.id, forKey: "id")
        kidRecord.setValue(kid.name, forKey: "name")
        kidRecord.setValue(kid.dob, forKey: "dob")
        kidRecord.setValue(kid.gender, forKey: "gender")
        kidRecord.setValue(kid.bloodType, forKey: "bloodType")
        
        // save/update record on Cloud
        privateDB.save(kidRecord, completionHandler: {(record, error) -> Void in
            if(error == nil){
                NSLog("Save to cloud kit")
            } else {
                NSLog(error!.localizedDescription)
            }
        })
    }
    
    // delete kid record from CloudKit private DB
    func deleteKid(kid: Kid){
        let predicate = NSPredicate(format: "id = %@", argumentArray: [kid.id!])
        let query = CKQuery(recordType: "Kid", predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(records, error) -> Void in
            if(error == nil && records!.count > 0){
                let recordId = records!.first!.recordID
                self.privateDB.delete(withRecordID: recordId, completionHandler: {(recordId, error) in
                    if(error == nil){
                        NSLog("Record deleted")
                        
                        self.getKids()
                    } else {
                        NSLog(error!.localizedDescription)
                    }
                })
            }
            else {
                NSLog(error!.localizedDescription)
            }
        })
    }
}

let cloudHelper = CloudHelper()

