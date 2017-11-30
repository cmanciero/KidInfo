//
//  MedicationViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/19/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class MedicationViewController: UIViewController {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDosage: UITextField!
    @IBOutlet weak var txtFreq: UITextField!
    @IBOutlet weak var txtType: UITextField!
    @IBOutlet weak var tvNotes: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnCheckMeds: UIButton!
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    var kid: Kid? = nil;
    var medication: Medication? = nil;
    let drugsDotComURL = "https://www.drugs.com/drug_interactions.html";

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
        if(medication != nil){
            titleBar.title = "Update Medication"
            txtDosage.text = medication!.dosage;
            txtFreq.text = medication!.frequence;
            tvNotes.text = medication!.howToTake;
            txtName.text = medication!.name;
            txtType.text = medication!.type;
            btnSave.isEnabled = true;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //---------------------------------
    // MARK: - Actions
    //---------------------------------
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }

    @IBAction func medNameChanged(_ sender: Any) {
        // check is medication name is empty
        if(txtName.text!.isEmpty){
            btnSave.isEnabled = false;
        } else {
            btnSave.isEnabled = true;
        }
    }
    // save medication to kid
    @IBAction func saveTapped(_ sender: Any) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        
        // if medication is not available
        if(medication == nil){
            let context = appDelegate.persistentContainer.viewContext;
            medication = Medication(context: context);
        }
        
        medication?.dosage = txtDosage.text;
        medication?.frequence = txtFreq.text;
        medication?.howToTake = tvNotes.text;
        medication?.name = txtName.text;
        medication?.type = txtType.text;
        medication?.kid = kid;
        
        appDelegate.saveContext();
        
        self.dismiss(animated: true, completion: nil);
    }
    
    // open URL to check for drug interactions
    @IBAction func checkMedsTapped(_ sender: Any) {
        let url = URL(string: drugsDotComURL)!;
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil);
    }
    
    //---------------------------------
    // MARK: - Notification Center
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
