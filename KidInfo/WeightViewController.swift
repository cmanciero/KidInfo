//
//  WeightViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/13/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class WeightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txtPounds: UITextField!
    @IBOutlet weak var txtOunces: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var weightTableView: UITableView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    var kid: Kid? = nil;
    var weight: Weight? = nil;
    var arrWeights: [Weight] = [];
    let datePicker = UIDatePicker();
    let dateFormatter = DateFormatter();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Do any additional setup after loading the view.
        //        btnSave.isEnabled = false;
        
        // create date picker
        createDatePicker();
        
        // select today
        dateFormatter.dateStyle = .medium;
        dateFormatter.timeStyle = .none;
        txtDate.text = dateFormatter.string(from: datePicker.date);
        
        // set table view
        weightTableView.dataSource = self;
        weightTableView.delegate = self;
        
        if(weight != nil){
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
            arrWeights = try context.fetch(Weight.fetchRequest());
            arrWeights.sort(by: { $0.date?.compare($1.date! as Date) == ComparisonResult.orderedDescending });
            
            // reload table view
            weightTableView.reloadData();
        } catch {}
    }
    
    /************************/
    // MARK: - Functions
    /************************/
    
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
    
    // calculate the weight
    func calculateWeight() -> Double{
        var weight = 0.0
        
        if let convertWeight = Double(txtPounds.text!){
            weight = convertWeight;
        }
        
        if var convertWeightOz = Double(txtOunces.text!){
            // convert ounce value
            if(convertWeightOz >= 16){
                weight += 1;
                convertWeightOz = convertWeightOz - 16;
            }
            weight += convertWeightOz * 0.1;
        }
        
        return weight;
    }
    
    /************************/
    // MARK: - tableView methods
    /************************/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWeights.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightTableViewCell", for: indexPath) as! WeightTableViewCell;
        let wt: Weight = arrWeights[indexPath.row];
        
        // set pounds
        let pounds = String(Int(wt.weight));
        // set ounces
        let ounces = String(wt.weight).components(separatedBy: ".")[1];
        
        cell.txtWeight?.text = "\(pounds) lbs \(ounces) oz";
        cell.txtDate?.text = dateFormatter.string(from: wt.date! as Date);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            // delete row from allergy table
            let wt = arrWeights[indexPath.row];
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
            context.delete(wt);
            (UIApplication.shared.delegate as! AppDelegate).saveContext();
            
            arrWeights.remove(at: indexPath.row);
            
            weightTableView.reloadData();
        }
    }
    
    /************************/
    // MARK: - Actions
    /************************/
    
    @IBAction func saveTapped(_ sender: Any) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        
        // if allergy is not available
        if(weight == nil){
            let context = appDelegate.persistentContainer.viewContext;
            weight = Weight(context: context);
        }
        
        // calculate the weight
        let calWeight = calculateWeight();
        if(calWeight > 0.0){
            weight!.weight = calWeight;
        }
        
        weight!.date = datePicker.date as NSDate;
        weight!.kid = kid;
        
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
