//
//  KidInfoViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/1/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class KidInfoViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITableViewDelegate, UITableViewDataSource,
UIPickerViewDelegate, UIPickerViewDataSource{
    
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
    @IBOutlet weak var doctorTableView: UITableView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var txtBloodType: UITextField!
    @IBOutlet weak var lblAllergies: UILabel!
    @IBOutlet weak var lblDoctors: UILabel!
    @IBOutlet weak var lblHeightVal: UILabel!
    @IBOutlet weak var lblWeightVal: UILabel!
    @IBOutlet weak var lblAllergyCount: UILabel!
    @IBOutlet weak var lblDoctorCount: UILabel!
    
    var kid: Kid? = nil;
    var imagePicker = UIImagePickerController();
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray);
    let activityView = UIView();
    var activityViewConstraints: [NSLayoutConstraint] = [];
    
    var selectedAllergy: Allergy? = nil;
    var selectedDoctor: Doctor? = nil;
    
    var aBloodTypes = ["A Positive", "B Positive", "A/B Positive", "O Positive",
                       "A Negative", "B Negative", "A/B Negative", "O Negative"];
    var bloodTypePicker = UIPickerView();
    
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
        
        // create blood type picker
        bloodTypePicker.dataSource = self;
        bloodTypePicker.delegate = self;
        createBloodTypePicker();
        
        // disable save button
        btnSave.isEnabled = false;
        
        // check if kid exist
        if(kid != nil){
            loadKidInfo();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // reload the allergies table view
        allergyTableView.reloadData();
        
        // check count of allergies
        checkAllergyTableView();
        
        // reload doctor's table view
        doctorTableView.reloadData();
        
        // check count of doctors
        checkDoctorTableView();
        
        // get context for CoreData
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
        
        do{
            // fetch to get all kids
            let arrKids = try context.fetch(Kid.fetchRequest()) as! [Kid];
            
            // find the right kid
            for item in arrKids {
                if(item.objectID == kid?.objectID){
                    kid = item;
                    break;
                }
            }
            
            // reload kid data
            loadKidInfo();
            
        } catch {}
    }
    
    /************************/
    // MARK: - tableView methods
    /************************/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // check for allergy table view
        if(tableView.isEqual(allergyTableView)){
            selectedAllergy = (kid!.allergies!.array as! [Allergy])[indexPath.row] as Allergy;
            performSegue(withIdentifier: "allergySegue", sender: nil);
        } else if(tableView.isEqual(doctorTableView)) {
            selectedDoctor = (kid!.doctors!.array as! [Doctor])[indexPath.row] as Doctor;
            performSegue(withIdentifier: "doctorSegue", sender: nil);
            
        }
        
        // deselect selected row
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0;
        if(tableView.isEqual(allergyTableView)){
            if(kid?.allergies != nil){
                rowCount = (kid!.allergies!.count);
            }
        }else if(tableView.isEqual(doctorTableView)) {
            if(kid?.doctors != nil){
                rowCount = (kid!.doctors!.count);
            }
        }
        
        return rowCount;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        if(tableView.isEqual(allergyTableView)){
            let allergy: Allergy = (kid!.allergies!.array as! [Allergy])[indexPath.row] as Allergy;
            
            cell.textLabel?.text = allergy.type;
            
            var image: UIImage = UIImage();
            if(allergy.level == "Severe"){
                image = UIImage(named: "severe")!;
            }
            
            cell.imageView?.image = image;
        }else if(tableView.isEqual(doctorTableView)) {
            let doctor: Doctor = (kid!.doctors!.array as! [Doctor])[indexPath.row] as Doctor;
            cell.textLabel?.text = doctor.name;
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            // delete row from allergy table
            if(tableView.isEqual(allergyTableView)){
                let allergy = (kid!.allergies!.array as! [Allergy])[indexPath.row] as Allergy;
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
                context.delete(allergy);
                (UIApplication.shared.delegate as! AppDelegate).saveContext();
                
                allergyTableView.reloadData();
                
                // check if kid has allergies
                checkAllergyTableView();
            }
                // delete row from doctor table
            else if(tableView.isEqual(doctorTableView)){
                let doctor = (kid!.doctors!.array as! [Doctor])[indexPath.row] as Doctor;
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
                context.delete(doctor);
                (UIApplication.shared.delegate as! AppDelegate).saveContext();
                
                doctorTableView.reloadData();
                
                // check if kid has allergies
                checkDoctorTableView();
            }
        }
    }
    
    /************************/
    // MARK: - PickerView methods
    /************************/
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aBloodTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return aBloodTypes[row];
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == bloodTypePicker){
            print(aBloodTypes[row]);
        }
    }
    
    /************************/
    // MARK: - Functions
    /************************/
    
    // load kid information
    func loadKidInfo(){
        // disable save button
        btnSave.isEnabled = true;
        txtName.text = kid!.name;
        titleName.title = txtName.text;
        
        btnDelete.isHidden = false;
        
        // check if avatar is set
        if(kid!.avatar != nil){
            let image = UIImage(data: kid!.avatar! as Data);
            btnAvatar.setBackgroundImage(image, for: .normal);
            btnAvatar.setTitle("Update photo", for: .normal);
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
        
        // set blood type
        if(kid!.bloodType != nil){
            txtBloodType.text = kid!.bloodType;
        }
        
        // set weight
        if((kid!.weights?.count)! > 0){
            lblWeightVal.isHidden = false;
            let latestKidWeight = kid!.weights?[kid!.weights!.count - 1] as! Weight;
            
            // set pounds
            let pounds = String(Int(latestKidWeight.weight));
            // set ounces
            let ounces = String(latestKidWeight.weight).components(separatedBy: ".")[1];
            
            lblWeightVal.text = "\(pounds) lbs \(ounces) oz";
        }
        
        // set height
        if((kid!.heights?.count)! > 0){
            lblHeightVal.isHidden = false;
            let latestKidHeight = kid!.heights?[kid!.heights!.count - 1] as! Height;
            
            // set height feet
            let feet = String(Int(latestKidHeight.height / 12.0));
            // set height inches
            let inches = String(Int(latestKidHeight.height.truncatingRemainder(dividingBy: 12.0)));
            
            lblHeightVal.text = "\(feet) ft \(inches) inches";
        }
        
        // check if kid has allergies
        checkAllergyTableView();
        
        // check if to display doctors count
        checkDoctorTableView();
    }
    
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
    
    // check if allergy table should be shown
    func checkAllergyTableView(){
        var allergyCount = 0;
        
        if(kid?.allergies != nil){
            allergyCount = (kid!.allergies?.count)!;
        }
        
        if(allergyCount > 0){
            if(allergyTableView.isHidden){
                allergyTableView.isHidden = false;
            }
            
            // check if to display allergies count
            if(allergyCount > 3){
                lblAllergyCount.text = "(\(allergyCount))";
            }
        } else {
            allergyTableView.isHidden = true;
        }
    }
    
    // check if doctor table should be shown
    func checkDoctorTableView(){
        var doctorCount = 0;
        if(kid?.doctors != nil){
            doctorCount = (kid!.doctors?.count)!;
        }
        
        if(doctorCount > 0){
            if(doctorTableView.isHidden){
                doctorTableView.isHidden = false;
            }
            
            // check if to display allergies count
            if(doctorCount > 3){
                lblDoctorCount.text = "(\(doctorCount))";
            }
        } else {
            doctorTableView.isHidden = true;
        }
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
    
    // create blood type picker
    func createBloodTypePicker(){
        let toolbar = UIToolbar();
        toolbar.sizeToFit();
        
        // done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(bloodTypeDonePressed));
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        
        // cancel button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(closePicker));
        
        // add buttons to button bar
        toolbar.setItems([cancelButton, flex, doneButton], animated: true);
        
        txtBloodType.inputAccessoryView = toolbar;
        txtBloodType.inputView = bloodTypePicker;
    }
    
    // Done pressed for Blood Type
    func bloodTypeDonePressed(){
        txtBloodType.text = aBloodTypes[bloodTypePicker.selectedRow(inComponent: 0)];
        closePicker();
    }
    
    // Close all pickers
    func closePicker(){
        self.view.endEditing(true);
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
            
        } else if(segue.identifier == "doctorSegue"){
            let nextVC: DoctorViewController = segue.destination as! DoctorViewController;
            nextVC.kid = kid;
            nextVC.doctor = selectedDoctor;
        } else if(segue.identifier == "weightSegue"){
            // get the tab bar controller
            let tabBar: WeightTabBarController = segue.destination as! WeightTabBarController;
            
            // pass data to the main view
            let nextVC: WeightViewController = tabBar.viewControllers?.first as! WeightViewController;
            nextVC.kid = kid;
            
            // pass data to the growth chart
            let secondVC: WeightGrowthChartViewController = tabBar.viewControllers?[1] as! WeightGrowthChartViewController;
            secondVC.kid = kid;
        } else if(segue.identifier == "heightSegue"){
            // get the tab bar controller
            let tabBar: HeightTabBarController = segue.destination as! HeightTabBarController;
            
            // pass data to the main view
            let nextVC: HeightViewController = tabBar.viewControllers?.first as! HeightViewController;
            nextVC.kid = kid;
            
            // pass data to the growth chart
            let secondVC: HeightGrowthChartViewController = tabBar.viewControllers?[1] as! HeightGrowthChartViewController;
            secondVC.kid = kid;
        }
    }
    
    /************************/
    // MARK: - Actions
    /************************/
    
    // check to see if a kid name exists
    @IBAction func checkForName(_ sender: Any) {
        if(txtName.text!.isEmpty){
            btnSave.isEnabled = false;
        } else {
            btnSave.isEnabled = true;
        }
    }
    
    // update title on name change
    @IBAction func nameUpdating(_ sender: Any) {
        titleName.title = txtName.text;
    }
    
    // Add allergy
    @IBAction func addAllergyTapped(_ sender: Any) {
        // reset selectedAllergy
        selectedAllergy = nil;
    }
    
    // Add doctor
    @IBAction func addDoctorTapped(_ sender: Any) {
        selectedDoctor = nil;
    }
    
    // Save kid
    @IBAction func saveTapped(_ sender: Any) {
        if(kid != nil){
            kid!.name = txtName.text;
            kid!.avatar = UIImagePNGRepresentation(btnAvatar.backgroundImage(for: .normal)!)! as NSData;
            
            // save DOB
            kid!.dob = dobPicker.date as NSDate;
            
            // save blood type
            kid!.bloodType = txtBloodType.text;
        } else {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
            
            let kid = Kid(context: context);
            kid.name = txtName.text;
            
            // check if avatar image was set
            if(btnAvatar.backgroundImage(for: .normal) != nil){
                kid.avatar = UIImagePNGRepresentation(btnAvatar.backgroundImage(for: .normal)!)! as NSData;
            }
            
            // save DOB
            if(txtDOB.text != nil && txtDOB.text != ""){
                kid.dob = dobPicker.date as NSDate;
            }
            
            // save blood type
            if(txtBloodType.text != nil && txtBloodType.text != ""){
                kid.bloodType = txtBloodType.text;
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
