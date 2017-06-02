//
//  KidInfoViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/1/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class KidInfoViewController: UIViewController {
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var btnAddUpdate: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    var kid: Kid? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if kid exist
        if(kid != nil){
            txtFirstName.text = kid!.firstName;
            
            btnAddUpdate.setTitle("Update", for: .normal);
            btnDelete.isHidden = false;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTapped(_ sender: Any) {
        // check if kid exists
        if(kid != nil){
            kid!.firstName = txtFirstName.text;
        } else {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
            
            let kid = Kid(context: context);
            kid.firstName = txtFirstName.text;
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext();
        
        navigationController?.popViewController(animated: true);
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
