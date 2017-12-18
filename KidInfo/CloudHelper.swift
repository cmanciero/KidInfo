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
    
    //---------------------------------
    // MARK: - KID
    //---------------------------------
    
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
    //    func saveKidInfo(kid: Kid){
    //        let predicate = NSPredicate(format: "id = %@", argumentArray: [kid.id!])
    //        let query = CKQuery(recordType: "Kid", predicate: predicate)
    //
    //        // make request to see if Kid exists
    //        privateDB.perform(query, inZoneWith: nil, completionHandler: {(records, error) -> Void in
    //            if(error == nil){
    //                if(records?.count == 0){
    //                    // save new kid
    //                    self.saveUpdateKidInfo(kid: kid);
    //                } else {
    //                    // update kid info
    //                    self.saveUpdateKidInfo(kid: kid, recordToUpdate: records!.first!);
    //                }
    //
    //                // get list of kids
    //                self.getKids();
    //            } else {
    //                NSLog(error!.localizedDescription)
    //            }
    //        })
    //    }
    
    // Save record to CloudKit private DB
    func saveRecordInfo(record: AnyObject, recordType: String){
        var predicate: NSPredicate
        
        // set predicate for correct type
        switch(recordType){
            case Utilities.RecordTypes.allergy:
                predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! Allergy).id!])
            case Utilities.RecordTypes.height:
                predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! Height).id!])
            case Utilities.RecordTypes.kid:
                predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! Kid).id!])
            case Utilities.RecordTypes.medication:
                predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! Medication).id!])
            case Utilities.RecordTypes.weight:
                predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! Weight).id!])
            default:
                predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! Kid).id!])
        }
        
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        // make request to see if Kid exists
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(records, error) -> Void in
            if(error == nil){
                if(records?.count == 0){
                    // save new record
                    self.saveUpdateRecord(record: record, recordType: recordType)
                    //                    self.saveUpdateKidInfo(kid: kid);
                } else {
                    // update kid info
                    self.saveUpdateRecord(record: record, recordType: recordType, recordToUpdate: records!.first!)
                    //                    self.saveUpdateKidInfo(kid: kid, recordToUpdate: records!.first!);
                }
                
                // get list of kids
                //                self.getKids();
            } else {
                NSLog(error!.localizedDescription)
            }
        })
    }
    
    // save/update record info
    private func saveUpdateRecord(record: AnyObject, recordType: String, recordToUpdate: CKRecord? = nil){
        var ckRecord: CKRecord;
        
        // check to see if updating existing record
        if(recordToUpdate != nil){
            // Update existing Kid Info
            ckRecord = recordToUpdate!
        } else {
            // save new kid info
            ckRecord = CKRecord(recordType: recordType)
        }
        
        switch recordType {
            // create Allergy record
            case Utilities.RecordTypes.allergy:
                ckRecord = createAllergyRecord(allergy: record as! Allergy, cloudRecord: ckRecord)
            // create Height record
            case Utilities.RecordTypes.height:
                ckRecord = createHeightRecord(height: record as! Height, cloudRecord: ckRecord)
            // create Kid record
            case Utilities.RecordTypes.kid:
                ckRecord = createKidRecord(kid: record as! Kid, cloudRecord: ckRecord)
            // create Medication record
            case Utilities.RecordTypes.medication:
                ckRecord = createMedicationRecord(medication: record as! Medication, cloudRecord: ckRecord)
            // create Weight record
            case Utilities.RecordTypes.weight:
                ckRecord = createWeightRecord(weight: record as! Weight, cloudRecord: ckRecord)
            // create Kid record
            default:
                ckRecord = createKidRecord(kid: record as! Kid, cloudRecord: ckRecord)
        }
        
        // save/update record on Cloud
        privateDB.save(ckRecord, completionHandler: {(record, error) -> Void in
            if(error == nil){
                NSLog("Save to cloud kit")
            } else {
                NSLog(error!.localizedDescription)
            }
        })
    }
    
    //---------------------------------
    // MARK: - CREATE CLOUD RECORDS
    //---------------------------------
    
    // Create Allergy Cloud Record
    private func createAllergyRecord(allergy: Allergy, cloudRecord: CKRecord) -> CKRecord{
        // set values
        cloudRecord.setValue(allergy.id, forKey: "id")
        cloudRecord.setValue(allergy.level, forKey: "level")
        cloudRecord.setValue(allergy.notes, forKey: "notes")
        cloudRecord.setValue(allergy.type, forKey: "type")
        
        return cloudRecord
    }
    
    // Create Height Cloud Record
    private func createHeightRecord(height: Height, cloudRecord: CKRecord) -> CKRecord{
        return cloudRecord
    }
    
    // Create Kid Cloud Record
    private func createKidRecord(kid: Kid, cloudRecord: CKRecord) -> CKRecord{
        // check if avatar set for kid
        if(kid.avatar != nil){
            // get avatar asset info
            let imageURL = getAvatarURL(kid: kid)
            let imageAsset = CKAsset(fileURL: imageURL as URL)
            cloudRecord.setValue(imageAsset, forKey: "avatar")
        }
        
        // set values
        cloudRecord.setValue(kid.id, forKey: "id")
        cloudRecord.setValue(kid.name, forKey: "name")
        cloudRecord.setValue(kid.dob, forKey: "dob")
        cloudRecord.setValue(kid.gender, forKey: "gender")
        cloudRecord.setValue(kid.bloodType, forKey: "bloodType")
        
        return cloudRecord
    }
    
    // Create Medication Cloud Record
    private func createMedicationRecord(medication: Medication, cloudRecord: CKRecord) -> CKRecord{
        return cloudRecord
    }
    
    // Create Weight Cloud Record
    private func createWeightRecord(weight: Weight, cloudRecord: CKRecord) -> CKRecord{
        return cloudRecord
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
    //    private func saveUpdateKidInfo(kid: Kid, recordToUpdate: CKRecord? = nil){
    //        var kidRecord: CKRecord;
    //
    //        // check to see if updating existing record
    //        if(recordToUpdate != nil){
    //            // Update existing Kid Info
    //            kidRecord = recordToUpdate!
    //        } else {
    //            // save new kid info
    //            kidRecord = CKRecord(recordType: "Kid")
    //        }
    //
    //        // check if avatar set for kid
    //        if(kid.avatar != nil){
    //            // get avatar asset info
    //            let imageURL = getAvatarURL(kid: kid)
    //            let imageAsset = CKAsset(fileURL: imageURL as URL)
    //            kidRecord.setValue(imageAsset, forKey: "avatar")
    //        }
    //
    //        // set values
    //        kidRecord.setValue(kid.id, forKey: "id")
    //        kidRecord.setValue(kid.name, forKey: "name")
    //        kidRecord.setValue(kid.dob, forKey: "dob")
    //        kidRecord.setValue(kid.gender, forKey: "gender")
    //        kidRecord.setValue(kid.bloodType, forKey: "bloodType")
    //
    //        // save/update record on Cloud
    //        privateDB.save(kidRecord, completionHandler: {(record, error) -> Void in
    //            if(error == nil){
    //                NSLog("Save to cloud kit")
    //            } else {
    //                NSLog(error!.localizedDescription)
    //            }
    //        })
    //    }
    
    //---------------------------------
    // MARK: - ALLERGY
    //---------------------------------
    //    func saveAllergyInfoForKid(kid: Kid, allergy:Allergy){
    //        let predicate = NSPredicate(format: "id = %@", argumentArray: [allergy.id!])
    //        let query = CKQuery(recordType: "Allergy", predicate: predicate)
    //
    //        // make request to see if Kid exists
    //        privateDB.perform(query, inZoneWith: nil, completionHandler: {(records, error) -> Void in
    //            if(error == nil){
    //                if(records?.count == 0){
    //                    // save new kid
    //                    self.saveUpdateAllergyForKid(kid: kid, allergy: allergy);
    //                } else {
    //                    // update kid info
    //                    self.saveUpdateAllergyForKid(kid: kid, allergy: allergy, recordToUpdate: records!.first!);
    //                }
    //            } else {
    //                NSLog(error!.localizedDescription)
    //            }
    //        })
    //    }
    
    // save Allergy record to cloud for kid
    //    private func saveUpdateAllergyForKid(kid: Kid, allergy: Allergy, recordToUpdate: CKRecord? = nil){
    //        var allergyRecord: CKRecord;
    //
    //        // check to see if updating existing record
    //        if(recordToUpdate != nil){
    //            // Update existing Allergy Info
    //            allergyRecord = recordToUpdate!
    //        } else {
    //            // save new Allergy info
    //            allergyRecord = CKRecord(recordType: "Allergy")
    //        }
    //
    //        // set values
    //        allergyRecord.setValue(allergy.id, forKey: "id")
    //        allergyRecord.setValue(allergy.level, forKey: "level")
    //        allergyRecord.setValue(allergy.notes, forKey: "notes")
    //        allergyRecord.setValue(allergy.type, forKey: "type")
    //
    //        // save/update record on Cloud
    //        privateDB.save(allergyRecord, completionHandler: {(record, error) -> Void in
    //            if(error == nil){
    //                NSLog("Allergy saved to cloud kit")
    //            } else {
    //                NSLog(error!.localizedDescription)
    //            }
    //        })
    //    }
    
    //---------------------------------
    // MARK: - DELETE
    //---------------------------------
    
    // delete record from CloudKit private DB
    func deleteType(recordToDelete: AnyObject, recordTypeToDelete: String){
        let predicate = NSPredicate(format: "id = %@", argumentArray: [recordToDelete["id"]])
        let query = CKQuery(recordType: recordTypeToDelete, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(records, error) -> Void in
            if(error == nil && records!.count > 0){
                let recordId = records!.first!.recordID
                self.privateDB.delete(withRecordID: recordId, completionHandler: {(recordId, error) in
                    if(error == nil){
                        NSLog("Record deleted")
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

