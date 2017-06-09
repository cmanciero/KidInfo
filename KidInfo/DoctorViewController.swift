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
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtNotes: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // style notes section
        txtNotes.layer.borderWidth = 1;
        txtNotes.layer.borderColor = UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor;
        txtNotes.layer.cornerRadius = 5;

        // Do any additional setup after loading the view.
        if(doctor != nil){
            titleBar.title = "Update Doctor";
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
