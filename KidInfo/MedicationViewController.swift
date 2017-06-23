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
    
    var kid: Kid? = nil;
    var medication: Medication? = nil;

    override func viewDidLoad() {
        super.viewDidLoad()
        print(kid);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }

    @IBAction func saveTapped(_ sender: Any) {
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
