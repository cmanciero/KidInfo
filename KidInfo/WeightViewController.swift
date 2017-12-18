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
    let datePicker = UIDatePicker();
    let dateFormatter = DateFormatter();
    let appDelegate = Utilities.getApplicationDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
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
        
    }
    
    //---------------------------------
    // MARK: - Notification Center
    //---------------------------------
    
//    func keyboardWillHide(noti: Notification) {
//        let contentInsets = UIEdgeInsets.zero
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
//    }
//    
//    func keyboardWillShow(noti: Notification) {
//        
//        guard let userInfo = noti.userInfo else { return }
//        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
//        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
//        
//        var contentInset:UIEdgeInsets = scrollView.contentInset
//        contentInset.bottom = keyboardFrame.size.height
//        scrollView.contentInset = contentInset
//    }
    
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
    @objc func dateDonePressed(){
        // format results
        txtDate.text = dateFormatter.string(from: datePicker.date);
        closePicker();
    }
    
    // Close all pickers
    @objc func closePicker(){
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
            weight += convertWeightOz * 0.01;
        }
        
        return weight;
    }
    
    // sort the weight values
    func sortWeightArray() -> [Any]{
        return kid!.weights!.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)]);
    }
    
    /************************/
    // MARK: - tableView methods
    /************************/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0;
        
        if(kid?.weights != nil){
            rowCount = kid!.weights!.count;
        }
        
        return rowCount;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sortedWeightArray: [Any] = sortWeightArray();
        let wt: Weight = (sortedWeightArray as! [Weight])[indexPath.row] as Weight;
//        arrWeights.sort(by: { $0.date?.compare($1.date! as Date) == ComparisonResult.orderedDescending });

        let cell = tableView.dequeueReusableCell(withIdentifier: "weightTableViewCell", for: indexPath) as! WeightTableViewCell;
        
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
            let sortedWeightArray: [Any] = sortWeightArray();
            let wt = (sortedWeightArray as! [Weight])[indexPath.row] as Weight;
            
            let context = appDelegate.persistentContainer.viewContext;
            context.delete(wt);
            appDelegate.saveContext();
            
            weightTableView.reloadData();
        }
    }
    
    /************************/
    // MARK: - Actions
    /************************/
    
    @IBAction func saveTapped(_ sender: Any) {
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
        
        weight!.date = datePicker.date;// as NSDate;
        weight!.kid = kid;
        
        appDelegate.saveContext();
        
        txtPounds.text = nil;
        txtOunces.text = nil;
        
        weightTableView.reloadData();
    }
    
    @IBAction func checkForWeightVal(_ sender: Any) {
        if(!txtPounds.text!.isEmpty || !txtOunces.text!.isEmpty){
            btnSave.isEnabled = true;
        } else {
            btnSave.isEnabled = false;
        }
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
