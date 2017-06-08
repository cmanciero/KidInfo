//
//  KidInfoViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/1/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class KidInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtWeightLbs: UITextField!
    @IBOutlet weak var txtWeightOz: UITextField!
    @IBOutlet weak var txtHeightFt: UITextField!
    @IBOutlet weak var txtHeightInches: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var titleName: UINavigationItem!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var allergyTableView: UITableView!
    @IBOutlet weak var lblAllergyCount: UILabel!
    @IBOutlet weak var lblDoctorCount: UILabel!
    @IBOutlet weak var doctorTableView: UITableView!
    
    var kid: Kid? = nil;
    var imagePicker = UIImagePickerController();
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray);
    let activityView = UIView();
    var activityViewConstraints: [NSLayoutConstraint] = [];
    
    var selectedAllergy: Allergy? = nil;
    var doctors = ["Branford Pediatrics", "Dr. Parker", "Dr. Kim", "Dr. Love"];
    
    // UIDatePicker for DOB
    let dobPicker = UIDatePicker();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // create the activity view
        createActivityView();
        
        // hide activity indicator if running
        if(activityIndicator.isAnimating){
            activityView.isHidden = true;
            activityIndicator.stopAnimating();
        }
        
        imagePicker.delegate = self;
        
        // allergyTableView
        allergyTableView.delegate = self;
        allergyTableView.dataSource = self;
        
        // doctorTableView
        doctorTableView.delegate = self;
        doctorTableView.dataSource = self;
        
        // style avatar button
        btnAvatar.layer.cornerRadius = btnAvatar.layer.frame.width / 2;
        btnAvatar.layer.borderWidth = 3;
        btnAvatar.layer.borderColor = UIColor.white.cgColor;
        btnAvatar.setTitle("Add photo", for: .normal);
        
        // create date picker for DOB
        createDatePicker();
        
        // check if kid exist
        if(kid != nil){
            txtName.text = kid!.name;
            titleName.title = txtName.text;
            
            btnDelete.isHidden = false;
            
            // check if avatar is set
            if(kid!.avatar != nil){
                let image = UIImage(data: kid!.avatar! as Data);
                btnAvatar.setBackgroundImage(image, for: .normal);
                btnAvatar.setTitle("Update photo", for: .normal);
            }
            
            // set height
            let height = kid!.height;
            if(height > 0){
                // set height feet
                txtHeightFt.text = String(Int(height / 12.0));
                // set height inces
                txtHeightInches.text = String(Int(height.truncatingRemainder(dividingBy: 12.0)));
            }
            
            // set weight
            let weight = kid!.weight;
            if(weight > 0){
                // set weight lbs
                txtWeightLbs.text = String(Int(weight));
                txtWeightOz.text = String(weight).components(separatedBy: ".")[1];
            }
            
            // set date of birth
            if(kid!.dob != nil){
                let dateFormatter = DateFormatter();
                dateFormatter.dateStyle = .medium;
                dateFormatter.timeStyle = .none;
                txtDOB.text = dateFormatter.string(from: kid!.dob! as Date);
                
                // set date picker to date of birth
                dobPicker.setDate(kid!.dob! as Date, animated: false);
            }
            
            // check if kid has allergies
            if((kid!.allergies?.count)! > 0){
                allergyTableView.isHidden = false;
                let allergyCount = (kid!.allergies?.count)!;
                
                // check if to display allergies count
                if(allergyCount > 3){
                    lblAllergyCount.isHidden = false;
                    lblAllergyCount.text = "\(allergyCount) allergies";
                }
            }
            
            // check if to display doctors count
            if(doctors.count > 3){
                lblDoctorCount.isHidden = false;
                lblDoctorCount.text = "\(doctors.count) doctors";
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // check for allergy table view
        if(tableView.isEqual(allergyTableView)){
            selectedAllergy = (kid!.allergies!.allObjects as! [Allergy])[indexPath.row] as Allergy;
            performSegue(withIdentifier: "allergySegue", sender: nil);
        } else if(tableView.isEqual(doctorTableView)) {
            print("doctor");
        }
        
        // deselect selected row
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0;
        if(tableView.isEqual(allergyTableView)){
            rowCount = (kid!.allergies?.count)!;
        }else if(tableView.isEqual(doctorTableView)) {
            rowCount = doctors.count;
        }
        
        return rowCount;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        if(tableView.isEqual(allergyTableView)){
            let allergy: Allergy = (kid!.allergies!.allObjects as! [Allergy])[indexPath.row] as Allergy;
            cell.textLabel?.text = allergy.type;
            
            var image: UIImage = UIImage();
            if(allergy.level == "Mild"){
                image = UIImage(named: "yellowDot.png")!;
            } else if(allergy.level == "Severe"){
                image = UIImage(named: "redDot.png")!;
            }
            
            cell.imageView?.image = image;
        }else if(tableView.isEqual(doctorTableView)) {
            cell.textLabel?.text = doctors[indexPath.row];
        }
        
        return cell;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        allergyTableView.reloadData();
        
        // check count of allergies
    }
    
    /************************/
    // Func
    /************************/
    
    // create the activity view
    func createActivityView(){
        activityView.alpha = 0.5;
        activityView.translatesAutoresizingMaskIntoConstraints = false;
        activityView.isHidden = true;
        activityView.backgroundColor = UIColor.white;
        self.view.addSubview(activityView);
        
        let topConstraint = activityView.topAnchor.constraint(equalTo: self.view.topAnchor);
        let bottomConstraint = activityView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor);
        let leftConstraint = activityView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor);
        let rightConstraint = activityView.rightAnchor.constraint(equalTo: self.view.rightAnchor);
        
        activityViewConstraints = [topConstraint, bottomConstraint, leftConstraint, rightConstraint];
        NSLayoutConstraint.activate(activityViewConstraints);
    }
    
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
    
    // calculate the weight
    func calculateWeight() -> Double{
        var weight = 0.0
        
        if let convertWeight = Double(txtWeightLbs.text!){
            weight = convertWeight;
        }
        
        if var convertWeightOz = Double(txtWeightOz.text!){
            // convert ounce value
            if(convertWeightOz >= 16){
                weight += 1;
                convertWeightOz = convertWeightOz - 16;
            }
            weight += convertWeightOz * 0.1;
        }
        
        return weight;
    }
    
    // set avatar button after selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage;
        
        btnAvatar.setBackgroundImage(image, for: .normal);
        imagePicker.dismiss(animated: true, completion: nil);
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "allergySegue"){
            let nextVC: AllergyViewController = segue.destination as! AllergyViewController;
            nextVC.kid = kid;
            nextVC.allergy = selectedAllergy;
            
        }
    }
    
    
    
    /************************/
    // Actions
    /************************/
    
    // update title on name change
    @IBAction func nameUpdating(_ sender: Any) {
        titleName.title = txtName.text;
    }
    
    // Add allergy
    @IBAction func addAllergyTapped(_ sender: Any) {
        performSegue(withIdentifier: "allergySegue", sender: nil);
    }
    
    // Save kid
    @IBAction func saveTapped(_ sender: Any) {
        if(kid != nil){
            kid!.name = txtName.text;
            kid!.avatar = UIImagePNGRepresentation(btnAvatar.backgroundImage(for: .normal)!)! as NSData;
            
            // calculate the weight
            let weight = calculateWeight();
            if(weight > 0.0){
                kid!.weight = weight;
            }
            
            // calculate the height
            let height = calculateHeight();
            if(height > 0.0){
                kid!.height = height;
            }
            
            // save DOB
            kid!.dob = dobPicker.date as NSDate;
        } else {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
            
            let kid = Kid(context: context);
            kid.name = txtName.text;
            
            // check if avatar image was set
            if(btnAvatar.backgroundImage(for: .normal) != nil){
                kid.avatar = UIImagePNGRepresentation(btnAvatar.backgroundImage(for: .normal)!)! as NSData;
            }
            
            // calculate the weight
            let weight = calculateWeight();
            if(weight > 0.0){
                kid.weight = weight;
            }
            
            // calculate the height
            let height = calculateHeight();
            if(height > 0.0){
                kid.height = height;
            }
            
            // save DOB
            if(txtDOB.text != nil && txtDOB.text != ""){
                kid.dob = dobPicker.date as NSDate;
            }
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
        // show waiting icon
        activityView.isHidden = false;
        activityIndicator.center = activityView.center;
        activityIndicator.hidesWhenStopped = true;
        activityView.addSubview(activityIndicator);
        
        // start animating
        activityIndicator.startAnimating();
        
        let warningAlert = UIAlertController(title: "Delete kid", message: "Are you sure you want to delete \(txtName!.text!)? This cannot be undone.", preferredStyle: .alert);
        warningAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            UIApplication.shared.beginIgnoringInteractionEvents();
            
            // get context
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
            
            // delete kid
            context.delete(self.kid!);
            
            // save context
            (UIApplication.shared.delegate as! AppDelegate).saveContext();
            
            // navigate back to main view
            self.navigationController?.popViewController(animated: true);
        }));
        warningAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.activityIndicator.stopAnimating();
            self.activityView.isHidden = true;
        }));
        self.present(warningAlert, animated: true, completion: nil);
    }
}
