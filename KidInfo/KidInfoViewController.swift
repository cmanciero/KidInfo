//
//  KidInfoViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/1/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class KidInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtHeight: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnAvatar: UIButton!

    var kid: Kid? = nil;
    var imagePicker = UIImagePickerController();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        imagePicker.delegate = self;
        
        // check if kid exist
        if(kid != nil){
            txtFirstName.text = kid!.firstName;
            txtLastName.text = kid!.lastName;
            btnDelete.isHidden = false;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        if(kid != nil){
            kid!.firstName = txtFirstName.text;
            kid!.lastName = txtLastName.text;
        } else {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
            
            let kid = Kid(context: context);
            kid.firstName = txtFirstName.text;
            kid.lastName = txtLastName.text;
            //            kid.height = txtHeight.text;
            //            kid.weight = txtWeight.text;
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext();
        
        navigationController?.popViewController(animated: true);
    }
    @IBAction func avatarTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary;
        
        present(imagePicker, animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage;
        
        btnAvatar.setBackgroundImage(image, for: .normal);
        imagePicker.dismiss(animated: true, completion: nil);
    }
    
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
