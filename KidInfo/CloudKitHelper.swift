//
//  CloudKitHelper.swift
//  KidInfo
//
//  Created by i814935 on 7/24/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitDelegate {
    func errorUpdating(error:NSError);
    func modelUpdated();
}

class CloudKitHelper{
    var container: CKContainer;
    let privateDB: CKDatabase;
    var delegate: CloudKitDelegate?;
    var arrKids: [Kid] = [];
    
    class func sharedInstance() -> CloudKitHelper{
        return cloudKitHelper;
    }
    
    init(){
        container = CKContainer.default();
        privateDB = container.privateCloudDatabase;
    }
    
    func saveRecord(){
        
    }
    
    func getKids() -> [Kid]{
        let predicate = NSPredicate(value: true);
        let sort = NSSortDescriptor(key: "name", ascending: true);
        
        let query = CKQuery(recordType: "Kid", predicate: predicate);
        query.sortDescriptors = [sort];
        
        return arrKids;
    }
}

let cloudKitHelper = CloudKitHelper();
