//
//  KidInfoViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/1/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class KidInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtWeightLbs: UITextField!
    @IBOutlet weak var txtWeightOz: UITextField!
    @IBOutlet weak var txtHeightFt: UITextField!
    @IBOutlet weak var txtHeightInches: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnAvatar: UIButton!
    
    var kid: Kid? = nil;
    var imagePicker = UIImagePickerController();
    
    // UIDatePicker for DOB
    let dobPicker = UIDatePicker();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        imagePicker.delegate = self;
        
        btnAvatar.layer.cornerRadius = btnAvatar.layer.frame.width / 2;
        btnAvatar.layer.borderWidth = 3;
        btnAvatar.layer.borderColor = UIColor.white.cgColor;
        
        // create date picker for DOB
        createDatePicker();
        
        // check if kid exist
        if(kid != nil){
            txtFirstName.text = kid!.firstName;
            txtLastName.text = kid!.lastName;
            btnDelete.isHidden = false;
            let image = UIImage(data: kid!.avatar! as Data);
            btnAvatar.setBackgroundImage(image, for: .normal);
            
            // set height
            let height = kid!.height;
            if(height > 0){
                // set height feet
                txtHeightFt.text = String(Int(height / 12.0));
                // set height inces
                txtHeightInches.text = String(Int(height.truncatingRemainder(dividingBy: 12.0)));
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /************************/
    // Func
    /************************/
    
    // create date picker for DOB
    func createDatePicker(){
        // set date mode
        dobPicker.datePickerMode = .date;
        
        // create toolbar to contain Done and Cancel
        let toolbar = UIToolbar();
        toolbar.sizeToFit();
        
        // done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dobDonePressed));
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        
        // cancel button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(closePicker));
        
        // add buttons to button bar
        toolbar.setItems([cancelButton, flex, doneButton], animated: true);
        
        // connect datepicker to txtDOB
        txtDOB.inputAccessoryView = toolbar;
        txtDOB.inputView = dobPicker;
    }
    
    // Done clicked for DOB picker
    func dobDonePressed(){
        // format results
        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .medium;
        dateFormatter.timeStyle = .none;
        
        txtDOB.text = dateFormatter.string(from: dobPicker.date);
        closePicker();
    }
    
    // Close all pickers
    func closePicker(){
        self.view.endEditing(true);
    }
    
    // calculate the height
    func calculateHeight() -> Double{
        var height = 0.0;
        
        if let convertHeightFt = Double(txtHeightFt.text!){
            height = convertHeightFt * 12;
        }
        
        if let convertHeightInches = Double(txtHeightInches.text!){
            height += convertHeightInches;
        }
        
        return height;
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage;
        
        btnAvatar.setBackgroundImage(image, for: .normal);
        imagePicker.dismiss(animated: true, completion: nil);
    }
    
    /************************/
    // Actions
    /************************/
    
    // Save kid
    @IBAction func saveTapped(_ sender: Any) {
        if(kid != nil){
            kid!.firstName = txtFirstName.text;
            kid!.lastName = txtLastName.text;
            kid!.avatar = UIImagePNGRepresentation(btnAvatar.backgroundImage(for: .normal)!)! as NSData;
            
            // calculate the height
            let height = calculateHeight();
            if(height > 0.0){
                kid!.height = height;
            }
        } else {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
            
            let kid = Kid(context: context);
            kid.firstName = txtFirstName.text;
            kid.lastName = txtLastName.text;
            kid.avatar = UIImagePNGRepresentation(btnAvatar.backgroundImage(for: .normal)!)! as NSData;
            
            // calculate the height
            let height = calculateHeight();
            if(height > 0.0){
                kid.height = height;
            }
            
            //            kid.weight = txtWeight.text;
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext();
        
        navigationController?.popViewController(animated: true);
    }
    
    
    // change/set avatar image
    @IBAction func avatarTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary;
        
        present(imagePicker, animated: true, completion: nil);
    }
    
    // delete kid
    @IBAction func deleteTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
        
        context.delete(kid!);
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext();
        navigationController?.popViewController(animated: true);
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
