//
//  AllergyViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/7/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class AllergyViewController: UIViewController {
    
    @IBOutlet weak var txtAllergyName: UITextField!
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var swSevereAllergy: UISwitch!
    
    var kid: Kid? = nil;
    var allergy: Allergy? = nil;
    let appDelegate = Utilities.getApplicationDelegate()
    let cloudHelper = CloudHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        btnDone.isEnabled = false;
        
        // style notes section
        txtNotes.layer.borderWidth = 1;
        txtNotes.layer.borderColor = UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor;
        txtNotes.layer.cornerRadius = 5;
        
        if(allergy != nil){
            btnDone.isEnabled = true;
            titleBar.title = "Update Allergy";
            txtAllergyName.text = allergy!.type;
            txtNotes.text = allergy!.notes;
            
            if(allergy!.level == "Severe"){    
                swSevereAllergy.isOn = true;
            }
            
            // loop through segments to find which one to select
//            let segments = segAllergyLevel.numberOfSegments;
//            for i in 0..<segments{
//                if(segAllergyLevel.titleForSegment(at: i) == allergy!.level){
//                    segAllergyLevel.selectedSegmentIndex = i;
//                    break;
//                }
//            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //---------------------------------
    // MARK: - NOTIFICATION CENTER
    //---------------------------------
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    //---------------------------------
    // MARK: - ACTIONS
    //---------------------------------
    
    // cancel adding/updating allergy
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    @IBAction func changingAllergyName(_ sender: Any) {
        // check to see if allergy name exists
        if(txtAllergyName.text!.isEmpty){
            btnDone.isEnabled = false;
        } else {
            btnDone.isEnabled = true;
        }
    }
    
    // Done adding/updating allergy
    @IBAction func doneTapped(_ sender: Any) {
        // if allergy is not available
        if(allergy == nil){
            let context = appDelegate.persistentContainer.viewContext;
            allergy = Allergy(context: context);
        }
        
        // set id value, if does not exist
        if(allergy!.id == nil){
            allergy!.id = UUID().uuidString;
        }
        
        allergy!.type = txtAllergyName.text;
//        allergy!.level = segAllergyLevel!.titleForSegment(at: segAllergyLevel.selectedSegmentIndex)!;
        if(swSevereAllergy.isOn){
            allergy!.level = "Severe";
        } else {
            allergy!.level = "Mild";
        }
        allergy!.notes = txtNotes.text;
        allergy!.kid = kid;
        
        // save allergy info to cloud for kid
        //cloudHelper.saveRecordInfo(record: kid!, recordType: Utilities.RecordTypes.allergy)//(kid: kid!, allergy: allergy!);
        
        appDelegate.saveContext();
        
        self.dismiss(animated: true, completion: nil);
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
