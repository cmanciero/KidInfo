//
//  Utilities.swift
//  KidInfo
//
//  Created by i814935 on 12/6/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import Foundation
import UIKit

class Utilities{
    // MARK: VARIABLES
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray);
    let activityView = UIView();
    var activityViewConstraints: [NSLayoutConstraint] = [];
    var arrLastUpdate: [LastUpdated] = []
    let appDelegate = Utilities.getApplicationDelegate()
    let cloudModel:CloudHelper = CloudHelper()
    var localTimeStamp: Date?
    
    static let KID: String = "Kid"
    class RecordTypes {
        static let kid: String = "Kid"
        static let allergy: String = "Allergy"
        static let doctorContact: String = "DoctorContact"
        static let medication: String = "Medication"
        static let height: String = "Height"
        static let weight: String = "Weight"
        static let lastUpdated: String = "LastUpdated"
    }
    
    // MARK: FUNCTIONS
    
    func getTimeStamp(){
        do{
            // fetch to get all timestamps
            let context = appDelegate.persistentContainer.viewContext;
            arrLastUpdate = try context.fetch(LastUpdated.fetchRequest());
            
            print("utilities timestamp")
            print(arrLastUpdate[0].timeStamp!)
            print("===========================")
            // if there is a local timestamp, set it
            if let timeStamp:Date = arrLastUpdate[0].timeStamp{
                self.localTimeStamp = timeStamp
            }
        } catch {}
    }
    
    // Set/update time stamp for any changes
    func updateTimeStamp(){
        let context = appDelegate.persistentContainer.viewContext;
        var lastUpdate: LastUpdated
        
        if(arrLastUpdate.isEmpty){
            lastUpdate = LastUpdated(context: context)
            lastUpdate.id = UUID().uuidString
            lastUpdate.timeStamp = Date()
        } else {
            lastUpdate = arrLastUpdate[0]
            lastUpdate.timeStamp = Date()
        }
        
        // save kid to iCloud
        self.cloudModel.saveRecordInfo(record: lastUpdate, recordType: Utilities.RecordTypes.lastUpdated);
        
        // save context
        self.appDelegate.saveContext();
    }
    
    // create the activity view
    func createActivityView(view: UIView){
        activityView.alpha = 0.5;
        activityView.translatesAutoresizingMaskIntoConstraints = false;
        activityView.isHidden = true;
        activityView.backgroundColor = UIColor.white;
        view.addSubview(activityView);
        
        let topConstraint = activityView.topAnchor.constraint(equalTo: view.topAnchor);
        let bottomConstraint = activityView.bottomAnchor.constraint(equalTo: view.bottomAnchor);
        let leftConstraint = activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor);
        let rightConstraint = activityView.rightAnchor.constraint(equalTo: view.rightAnchor);
        
        activityViewConstraints = [topConstraint, bottomConstraint, leftConstraint, rightConstraint];
        NSLayoutConstraint.activate(activityViewConstraints);
    }
    
    // show activity indicator
    func showActivityIndicator(){
        // show waiting icon
        activityView.isHidden = false;
        activityIndicator.center = activityView.center;
        activityIndicator.hidesWhenStopped = true;
        activityView.addSubview(activityIndicator);
        
        // start animating
        activityIndicator.startAnimating();
    }
    
    // hide activity indicator
    func hideActivityIndicator(){
        self.activityIndicator.stopAnimating();
        self.activityView.isHidden = true;
    }
    
    // MARK: STATIC FUNCTIONS
    
    // Get AppDelegate
    class func getApplicationDelegate() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // Make sure correct image orientation is saved
    class func imageOrientation(_ src:UIImage)->UIImage {
        if src.imageOrientation == UIImageOrientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        
        return img
    }
}

