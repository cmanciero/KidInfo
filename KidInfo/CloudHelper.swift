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
    func modelUpdated(results: [CKRecord])
}

class CloudHelper{
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    var delegate: CloudHelperDelegate?
    var timeStamp: Date?
    
    class func sharedInstance() -> CloudHelper{
        return cloudHelper
    }
    
    init(){
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    //---------------------------------
    // MARK: - TIMESTAMP
    //---------------------------------
    
    func getTimeStamp(){
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "LastUpdated",
                            predicate:  predicate)
        
        self.privateDB.perform(query, inZoneWith: nil, completionHandler: {results, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.errorUpdating(error: error! as NSError)
                    return
                }
            } else {
                DispatchQueue.main.async {
                    var ckRecord = CKRecord(recordType: Utilities.RecordTypes.lastUpdated)
                    ckRecord = results!.first!
                    print("iCloud timestamp")
                    
                    if let timeStamp = ckRecord.value(forKey: "timeStamp") as? Date{
                        self.timeStamp = timeStamp
                        print(self.timeStamp!)
                    }
                    print("======================")
                    return
                }
            }
        })
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
                    self.delegate?.modelUpdated(results: results!)
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
        var predicate: NSPredicate = createPredicate(record: record, recordType: recordType)
        
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        // make request to see if Kid exists
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(records, error) -> Void in
            if(error == nil){
                if(records?.count == 0){
                    // save new record
                    self.saveUpdateRecord(record: record, recordType: recordType)
                } else {
                    // update kid info
                    self.saveUpdateRecord(record: record, recordType: recordType, recordToUpdate: records!.first!)
                }
                
                // get list of kids
                // self.getKids();
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
            // create LastUpdated record
            case Utilities.RecordTypes.lastUpdated:
                ckRecord = createLastUpdatedRecord(lastUpdated: record as! LastUpdated, cloudRecord: ckRecord)
            // create DoctorContact record
            case Utilities.RecordTypes.doctorContact:
                ckRecord = createDoctorContactRecord(doctorContact: record as! DoctorContact, cloudRecord: ckRecord)
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
        // set values
        cloudRecord.setValue(height.id, forKey: "id")
        cloudRecord.setValue(height.date, forKey: "date")
        cloudRecord.setValue(height.height, forKey: "height")
        
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
        // set values
        cloudRecord.setValue(medication.id, forKey: "id")
        cloudRecord.setValue(medication.name, forKey: "name")
        cloudRecord.setValue(medication.type, forKey: "type")
        cloudRecord.setValue(medication.dosage, forKey: "dosage")
        cloudRecord.setValue(medication.frequency, forKey: "frequency")
        cloudRecord.setValue(medication.howToTake, forKey: "howToTake")
        
        return cloudRecord
    }
    
    // Create Weight Cloud Record
    private func createWeightRecord(weight: Weight, cloudRecord: CKRecord) -> CKRecord{
        // set values
        cloudRecord.setValue(weight.id, forKey: "id")
        cloudRecord.setValue(weight.date, forKey: "date")
        cloudRecord.setValue(weight.weight, forKey: "weight")
        
        return cloudRecord
    }
    
    // Create DoctorContact Cloud Record
    private func createDoctorContactRecord(doctorContact: DoctorContact, cloudRecord: CKRecord) -> CKRecord{
        // set values
        cloudRecord.setValue(doctorContact.contactId, forKey: "contactId")
        cloudRecord.setValue(doctorContact.id, forKey: "id")
        
        return cloudRecord
    }
    
    
    // Create LastUpdated Record
    private func createLastUpdatedRecord(lastUpdated: LastUpdated, cloudRecord: CKRecord) ->CKRecord{
        cloudRecord.setValue(lastUpdated.id, forKey: "id")
        cloudRecord.setValue(lastUpdated.timeStamp, forKey: "timeStamp")
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
    
    // create predicate to use for iCloud search
    private func createPredicate(record: AnyObject, recordType: String) -> NSPredicate{
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
        case Utilities.RecordTypes.lastUpdated:
            predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! LastUpdated).id!])
        case Utilities.RecordTypes.doctorContact:
            predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! DoctorContact).id!])
        default:
            predicate = NSPredicate(format: "id = %@", argumentArray: [(record as! Kid).id!])
        }
        
        return predicate
    }
    
    //---------------------------------
    // MARK: - DELETE
    //---------------------------------
    
    // delete record from CloudKit private DB
    func deleteType(recordToDelete: AnyObject, recordTypeToDelete: String){
        let predicate:NSPredicate = createPredicate(record: recordToDelete, recordType: recordTypeToDelete)
        
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

