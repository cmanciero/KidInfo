//
//  HeightViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/13/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class HeightViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var txtFeet: UITextField!
    @IBOutlet weak var txtInches: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var heightTableView: UITableView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    var kid: Kid? = nil;
    var height: Height? = nil;
    var arrHeights: [Height] = [];
    var datePicker = UIDatePicker();
    let dateFormatter = DateFormatter();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heightTableView.dataSource = self;
        heightTableView.delegate = self;
        
        // Do any additional setup after loading the view.
//        btnSave.isEnabled = false;
        
        // create date picker
        createDatePicker();
        
        // select today
        dateFormatter.dateStyle = .medium;
        dateFormatter.timeStyle = .none;
        txtDate.text = dateFormatter.string(from: datePicker.date);
        
        if(height != nil){
            btnSave.isEnabled = true;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // get context for CoreData
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
        
        do{
            // fetch to get all kids
            arrHeights = try context.fetch(Height.fetchRequest());
            
            // reload table view
            heightTableView.reloadData();
        } catch {}
    }
    
    /************************/
    // Functions
    /************************/
    
    // calculate the height
    func calculateHeight() -> Double{
        var height = 0.0;
        
        if let convertHeightFt = Double(txtFeet.text!){
            height = convertHeightFt * 12;
        }
        
        if let convertHeightInches = Double(txtInches.text!){
            height += convertHeightInches;
        }
        
        return height;
    }
    
    // create date picker for DOB
    func createDatePicker(){
        // set date mode
        datePicker.datePickerMode = .date;
        
        // create toolbar to contain Done and Cancel
        let toolbar = UIToolbar();
        toolbar.sizeToFit();
        
        // done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateDonePressed));
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        
        // cancel button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(closePicker));
        
        // add buttons to button bar
        toolbar.setItems([cancelButton, flex, doneButton], animated: true);
        
        // connect datepicker to txtDOB
        txtDate.inputAccessoryView = toolbar;
        txtDate.inputView = datePicker;
    }
    
    // Done clicked for DOB picker
    func dateDonePressed(){
        // format results
        txtDate.text = dateFormatter.string(from: datePicker.date);
        closePicker();
    }
    
    // Close all pickers
    func closePicker(){
        self.view.endEditing(true);
    }
    
    /************************/
    // MARK: - tableView methods
    /************************/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHeights.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "heightTableViewCell", for: indexPath) as! HeightTableViewCell;
        let ht: Height = arrHeights[indexPath.row];
        
        // set height feet
        let feet = String(Int(ht.height / 12.0));
        // set height inches
        let inches = String(Int(ht.height.truncatingRemainder(dividingBy: 12.0)));
        
        cell.txtHeight?.text = "\(feet) ft \(inches) inches";
        cell.txtDate?.text = dateFormatter.string(from: ht.date! as Date);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            // delete row from allergy table
            let ht = arrHeights[indexPath.row];
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
            context.delete(ht);
            (UIApplication.shared.delegate as! AppDelegate).saveContext();
            
            arrHeights.remove(at: indexPath.row);
            heightTableView.reloadData();
        }
    }

    
    /************************/
    // Actions
    /************************/
    
    @IBAction func saveTapped(_ sender: Any) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        
        // if allergy is not available
        if(height == nil){
            let context = appDelegate.persistentContainer.viewContext;
            height = Height(context: context);
        }
        
        // calculate the height
        let calcHeight = calculateHeight();
        if(calcHeight > 0.0){
            height!.height = calcHeight;
        }
        
        height!.date = datePicker.date as NSDate;
        height!.kid = kid;
        
        appDelegate.saveContext();
        
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
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
