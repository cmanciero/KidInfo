//
//  DoctorViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/9/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class DoctorViewController: UIViewController {
    var kid: Kid? = nil;
    var doctor: Doctor? = nil;
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var txtDoctorName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtAddress2: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtPostalCode: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let appDelegate = Utilities.getApplicationDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // style notes section
        txtNotes.layer.borderWidth = 1;
        txtNotes.layer.borderColor = UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor;
        txtNotes.layer.cornerRadius = 5;

        // Do any additional setup after loading the view.
        if(doctor != nil){
            titleBar.title = "Update Doctor";
            
            txtDoctorName.text = doctor!.name;
            txtAddress.text = doctor!.address;
            txtAddress2.text = doctor!.address2;
            txtCity.text = doctor!.city;
            txtState.text = doctor!.state;
            txtPostalCode.text = doctor!.postalCode;
            txtEmail.text = doctor!.email;
            txtPhoneNumber.text = doctor!.phoneNumber;
            txtNotes.text = doctor!.notes;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //---------------------------------
    // MARK: - Actions
    //---------------------------------
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        // if allergy is not available
        if(doctor == nil){
            let context = appDelegate.persistentContainer.viewContext;
            doctor = Doctor(context: context);
        }
        
        doctor!.name = txtDoctorName.text;
        doctor!.address = txtAddress.text;
        doctor!.address2 = txtAddress2.text;
        doctor!.city = txtCity.text;
        doctor!.state = txtState.text;
        doctor!.postalCode = txtPostalCode.text;
        doctor!.email = txtEmail.text;
        doctor!.phoneNumber = txtPhoneNumber.text;
        doctor!.notes = txtNotes.text;
        doctor!.kid = kid;
        
        appDelegate.saveContext();
        
        self.dismiss(animated: true, completion: nil);
    }

    @IBAction func phoneNumberFormat(_ sender: Any) {
        if(!txtPhoneNumber.text!.isEmpty){
            let numberCount = txtPhoneNumber.text!.characters.count;
            // add () around number
            if(numberCount == 3){
                txtPhoneNumber.text = "(\(txtPhoneNumber.text!))";
                
                txtPhoneNumber.text!.insert(" ", at: txtPhoneNumber.text!.index(after: txtPhoneNumber.text!.index(txtPhoneNumber.text!.startIndex, offsetBy: 4)));
            }
            
            // add space between ) and number
            if(numberCount == 9){
                txtPhoneNumber.text = "\(txtPhoneNumber.text!)-";
            }
        }
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
