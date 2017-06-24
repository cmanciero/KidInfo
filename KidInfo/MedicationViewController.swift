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
    
    var kid: Kid? = nil;
    var medication: Medication? = nil;

    override func viewDidLoad() {
        super.viewDidLoad()
        print(kid);
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
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
    
    //---------------------------------
    // MARK: - Notification Center
    //---------------------------------
    
    func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillShow(noti: Notification) {
        
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
