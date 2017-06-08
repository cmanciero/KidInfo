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
    @IBOutlet weak var segAllergyLevel: UISegmentedControl!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    var kid: Kid? = nil;
    var allergy: Allergy? = nil;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(allergy != nil){
            titleBar.title = "Update Allergy";
            txtAllergyName.text = allergy?.type;
            
            // loop through segments to find which one to select
            let segments = segAllergyLevel.numberOfSegments;
            for i in 0..<segments{
                if(segAllergyLevel.titleForSegment(at: i) == allergy?.level){
                    segAllergyLevel.selectedSegmentIndex = i;
                    break;
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // cancel adding/updating allergy
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    // Done adding/updating allergy
    @IBAction func doneTapped(_ sender: Any) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        
        // if allergy is not available
        if(allergy == nil){
            let context = appDelegate.persistentContainer.viewContext;
            allergy = Allergy(context: context);
        }
        
        allergy!.type = txtAllergyName.text;
        allergy!.level = segAllergyLevel!.titleForSegment(at: segAllergyLevel.selectedSegmentIndex)!;
        allergy!.kid = kid;
        
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
