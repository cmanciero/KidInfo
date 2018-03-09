//
//  KidInfoViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/1/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class KidInfoViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITableViewDelegate, UITableViewDataSource,
    UIPickerViewDelegate, UIPickerViewDataSource,
    UITextFieldDelegate,
CNContactPickerDelegate{
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var titleName: UINavigationItem!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var allergyTableView: UITableView!
    @IBOutlet weak var doctorTableView: UITableView!
    @IBOutlet weak var medicationTableView: UITableView!
    @IBOutlet weak var txtBloodType: UITextField!
    @IBOutlet weak var lblAllergies: UILabel!
    @IBOutlet weak var lblDoctors: UILabel!
    @IBOutlet weak var btnWeightVal: UIButton!
    @IBOutlet weak var btnHeightVal: UIButton!
    @IBOutlet weak var lblAllergyCount: UILabel!
    @IBOutlet weak var lblDoctorCount: UILabel!
    @IBOutlet weak var lblMedicationCount: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var segGender: UISegmentedControl!
    
    // CloudKit model
    let cloudModel:CloudHelper = CloudHelper()
    
    // array of doctor contacts
    var doctors = [CNContact]();
    
    // store contact store
    var contactStore = CNContactStore();

    // selected kid object
    var kid: Kid? = nil;
    
    // image picker control for avatar
    var imagePicker = UIImagePickerController();
    
    // selected doctor contact to add to list of doctors
    var selectedDoctorContact: DoctorContact? = nil;
    
    var selectedAllergy: Allergy? = nil;
    var selectedDoctor: Doctor? = nil;
    var selectedMedication: Medication? = nil;
    
    var aBloodTypes = ["A Positive", "B Positive", "A/B Positive", "O Positive",
                       "A Negative", "B Negative", "A/B Negative", "O Negative"];
    var bloodTypePicker = UIPickerView();
    
    // UIDatePicker for DOB
    let dobPicker = UIDatePicker();
    
    let utilities = Utilities();
    
    let appDelegate = Utilities.getApplicationDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        btnHeightVal.setTitle("", for: .normal)
        btnWeightVal.setTitle("", for: .normal)
        
        // create the activity view
        utilities.createActivityView(view: self.view);
        
        // show activity indicator
        utilities.showActivityIndicator();
        
        imagePicker.delegate = self;
        
        // allergyTableView
        allergyTableView.delegate = self;
        allergyTableView.dataSource = self;
        
        // doctorTableView
        doctorTableView.delegate = self;
        doctorTableView.dataSource = self;
        
        // medicationTableView
        medicationTableView.delegate = self;
        medicationTableView.dataSource = self;
        
        // add border radius to avatar image
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2;
        imgAvatar.layer.borderWidth = 3;
        imgAvatar.layer.borderColor = UIColor.white.cgColor;
        
        // create date picker for DOB
        createDatePicker();
        
        // create blood type picker
        bloodTypePicker.dataSource = self;
        bloodTypePicker.delegate = self;
        createBloodTypePicker();
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
        
        // reload medication table view
        medicationTableView.reloadData();
        
        // check medication table vie
        checkMedicationTableView();
        
        // get context for CoreData
        let context = appDelegate.persistentContainer.viewContext;
        
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
            if(kid != nil){
                loadKidInfo();
            }
            
        } catch {}
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        // save kid info on keyboard close
        self.saveKidInfo();
        
        return true;
    }
    
    /************************/
    // MARK: - TABLEVIEW METHODS
    /************************/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // check for allergy table view
        if(tableView.isEqual(allergyTableView)){
            let sortedAllergies = sortAllergies();
            selectedAllergy = (sortedAllergies as! [Allergy])[indexPath.row] as Allergy;
            performSegue(withIdentifier: "allergySegue", sender: nil);
        } else if(tableView.isEqual(doctorTableView)) {
            //            let sortedDoctors = sortDoctors();
            //            selectedDoctor = (sortedDoctors as! [Doctor])[indexPath.row] as Doctor;
            //            performSegue(withIdentifier: "doctorSegue", sender: nil);
//            let selectedDoctor = doctors[indexPath.row];
            
            // get selected contact
            let contact = kid!.doctorContacts![indexPath.row] as! DoctorContact;
            
            // get contact object
            var selectedDoctor = self.findContactById(contact: contact);
            
            // check if required keys are set
            if !selectedDoctor.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
                do {
                    selectedDoctor = try self.contactStore.unifiedContact(withIdentifier: selectedDoctor.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
                }
                catch { }
            }
            
            // create/display controller for contacts
            let contactViewController = CNContactViewController(for: selectedDoctor);
            contactViewController.contactStore = self.contactStore;
            navigationController?.pushViewController(contactViewController, animated: true)
        } else if(tableView.isEqual(medicationTableView)) {
            let sortedMedications = sortMedications();
            selectedMedication = (sortedMedications as! [Medication])[indexPath.row] as Medication;
            performSegue(withIdentifier: "medicationSegue", sender: nil);
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
        } else if(tableView.isEqual(doctorTableView)) {
            //            if(kid?.doctors != nil){
            //                rowCount = (kid!.doctors!.count);
            //            }
            rowCount = (kid!.doctorContacts!.count);//doctors.count;
        } else if(tableView.isEqual(medicationTableView)) {
            if(kid?.medications != nil){
                rowCount = (kid!.medications!.count);
            }
        }
        
        return rowCount;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        if(tableView.isEqual(allergyTableView)){
            let sortedAllergies = sortAllergies();
            let allergy: Allergy = (sortedAllergies as! [Allergy])[indexPath.row] as Allergy;
            
            cell.textLabel?.text = allergy.type;
            
            var image: UIImage = UIImage();
            if(allergy.level == "Severe"){
                image = UIImage(named: "severe")!;
            }
            
            cell.imageView?.image = image;
        } else if(tableView.isEqual(doctorTableView)) {
            //            let sortedDoctors = sortDoctors();
            //            let doctor: Doctor = (sortedDoctors as! [Doctor])[indexPath.row] as Doctor;
            //            cell.textLabel?.text = doctor.name;
            
//            let currentDoctor = doctors[indexPath.row]
            let currentDoctor = kid!.doctorContacts![indexPath.row] as! DoctorContact;
            
            let foundDoctor = self.findContactById(contact: currentDoctor);
//            cell.textLabel?.text = currentDoctor.contactId;//"\(currentDoctor.givenName) \(currentDoctor.familyName)";
            cell.textLabel?.text = CNContactFormatter.string(from: foundDoctor, style: .fullName);
            
        } else if(tableView.isEqual(medicationTableView)) {
            let sortedMedications = sortMedications();
            let medication: Medication = (sortedMedications as! [Medication])[indexPath.row] as Medication;
            cell.textLabel?.text = medication.name;
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            // delete row from allergy table
            if(tableView.isEqual(allergyTableView)){
                let sortedAllergies = sortAllergies();
                let allergy = (sortedAllergies as! [Allergy])[indexPath.row] as Allergy;
                
                // delete from iCloud
                self.cloudModel.deleteType(recordToDelete: allergy, recordTypeToDelete: Utilities.RecordTypes.allergy)
                
                let context = appDelegate.persistentContainer.viewContext;
                context.delete(allergy);
                appDelegate.saveContext();
                
                allergyTableView.reloadData();
                
                // check if kid has allergies
                checkAllergyTableView();
            }
                // delete row from doctor table
            else if(tableView.isEqual(doctorTableView)){
//                let sortedDoctors = sortDoctors();
//                let doctor = (sortedDoctors as! [Doctor])[indexPath.row] as Doctor;
                
                let doctor = kid!.doctorContacts![indexPath.row] as! DoctorContact;
                
                self.cloudModel.deleteType(recordToDelete: doctor, recordTypeToDelete: Utilities.RecordTypes.doctorContact)
                
                let context = appDelegate.persistentContainer.viewContext;
                context.delete(doctor);
                appDelegate.saveContext();
                
                doctorTableView.reloadData();
                
                // check if kid has doctors
                checkDoctorTableView();
            }
                // delete row from medication table
            else if(tableView.isEqual(medicationTableView)){
                let sortedMedications = sortMedications();
                let medication = (sortedMedications as! [Medication])[indexPath.row] as Medication;
                
                self.cloudModel.deleteType(recordToDelete: medication, recordTypeToDelete: Utilities.RecordTypes.medication)
                
                let context = appDelegate.persistentContainer.viewContext;
                context.delete(medication);
                appDelegate.saveContext();
                
                medicationTableView.reloadData();
                
                // check if kid has medication
                checkMedicationTableView();
            }
        }
    }
    
    /************************/
    // MARK: - PICKERVIEW METHODS
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
    // MARK: - FUNCTIONS
    /************************/
    
    // save kid information
    func saveKidInfo(){
        kid!.name = txtName.text;
        if(imgAvatar.image != nil){
            kid!.avatar = UIImageJPEGRepresentation(imgAvatar.image!, 1);
//            kid!.avatar = UIImagePNGRepresentation(imgAvatar.image!);
        }
        
        // save gender
        if(segGender.selectedSegmentIndex > -1){
            kid!.gender = segGender.titleForSegment(at: segGender.selectedSegmentIndex);
        }
        
        // save DOB
        if(txtDOB.text != nil && txtDOB.text != ""){
            kid!.dob = dobPicker.date;
        }
        
        // save blood type
        if(txtBloodType.text != nil && txtBloodType.text != ""){
            kid!.bloodType = txtBloodType.text;
        }
    
        // save kid to iCloud
        cloudModel.saveRecordInfo(record: kid!, recordType: Utilities.RecordTypes.kid);
        
        appDelegate.saveContext();
    }
    
    // load kid information
    func loadKidInfo(){
        txtName.text = kid!.name;
        titleName.title = txtName.text;
        
        btnDelete.isHidden = false;
        
        // check if avatar is set
        if(kid!.avatar != nil){
            let image = UIImage(data: kid!.avatar! as Data);
            imgAvatar.image = image;
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
        
        // set gender
        if(kid!.gender != nil){
            // loop through segments to find which one to select
            let segments = segGender.numberOfSegments;
            for i in 0..<segments{
                if(segGender.titleForSegment(at: i) == kid!.gender){
                    segGender.selectedSegmentIndex = i;
                    break;
                }
            }
        }
        
        // set blood type
        if(kid!.bloodType != nil){
            txtBloodType.text = kid!.bloodType;
        }
        
        // set weight
        if((kid!.weights?.count)! > 0){
            btnWeightVal.isHidden = false;
            let sortedWeightArray = sortWeightArray();
            let latestKidWeight = sortedWeightArray[0] as! Weight;
            
            // set pounds
            let pounds = Int(latestKidWeight.weight / 16.0);
            
            // set ounces
            let ounces = Int(latestKidWeight.weight.truncatingRemainder(dividingBy: 16.0));
            
            btnWeightVal.setTitle("\(pounds) lbs \(ounces) oz", for: .normal);
        }
        
        // set height
        if((kid!.heights?.count)! > 0){
            btnHeightVal.isHidden = false;
            let sortedHeightArray = sortHeightArray();
            let latestKidHeight = sortedHeightArray[0] as! Height;
            
            // set height feet
            let feet = Int(latestKidHeight.height / 12.0);
            // set height inches
            let inches = Int(latestKidHeight.height.truncatingRemainder(dividingBy: 12.0));
            
            btnHeightVal.setTitle("\(feet) ft \(inches) inches", for: .normal)
        }
        
        // check if kid has allergies
        checkAllergyTableView();
        
        // check if to display doctors count
        checkDoctorTableView();
        
        // check if kid has medications
        checkMedicationTableView();
        
        // hide activity indicator
        utilities.hideActivityIndicator();
    }
    
    // sort the weight values
    func sortWeightArray() -> [Any]{
        return kid!.weights!.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)]);
    }
    
    // sort the height values
    func sortHeightArray() -> [Any]{
        return kid!.heights!.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)]);
    }
    
    // Find contact
    func findContactById(contact: DoctorContact) -> CNContact{
        var foundContact: CNContact = CNContact();
        
        do {
            let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)];
            let contactRefetched = try appDelegate.contactStore.unifiedContact(withIdentifier: contact.contactId!, keysToFetch: keys as [CNKeyDescriptor]);
            
            foundContact = contactRefetched;
        }
        catch{
            print("Unable to find contact with identifier: \(contact.contactId ?? "")");
        }
        
        return foundContact;
    }
    
    // check if allergy table should be shown
    func checkAllergyTableView(){
        var allergyCount = 0;
        
        if(kid?.allergies != nil){
            allergyCount = (kid!.allergies?.count)!;
        }
        
        if(allergyCount > 0){
            if(allergyTableView.isHidden){
//                allergyTableView.isHidden = false;
            }
            
            lblAllergyCount.text = "(\(allergyCount))";
//            lblAllergyCount.isHidden = false;
        } else {
//            allergyTableView.isHidden = true;
            lblAllergyCount.text = "";
        }
    }
    
    // sort allergies array
    func sortAllergies() -> [Any]{
        return kid!.allergies!.sortedArray(using: [NSSortDescriptor(key: "type", ascending: true)]);
    }
    
    // check if doctor table should be shown
    func checkDoctorTableView(){
        var doctorCount = 0;
//        if(kid?.doctors != nil){
//            doctorCount = (kid!.doctors?.count)!;
//        }
        
        if(kid?.doctorContacts != nil){
            doctorCount = (kid!.doctorContacts?.count)!;
        }
        
        if(doctorCount > 0){
//            if(doctorTableView.isHidden){
//                doctorTableView.isHidden = false;
//            }
//            viewDoctor.frame = CGRect(x: 0, y: 0, width: 375, height: 170);
            lblDoctorCount.text = "(\(doctorCount))";
            lblDoctorCount.isHidden = false;
        } else {
//            doctorTableView.isHidden = true;
            lblDoctorCount.text = "";
//            viewDoctor.frame = CGRect(x: 0, y: 0, width: 375, height: 50);
        }
//        doctorTableView.isHidden = false;
    }
    
    // sort doctors array
    func sortDoctors() -> [Any]{
        return kid!.doctors!.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]);
    }
    
    // check if medication table should be shown
    func checkMedicationTableView(){
        var medicationCount = 0;
        if(kid?.medications != nil){
            medicationCount = (kid!.medications?.count)!;
        }
        
        if(medicationCount > 0){
            if(medicationTableView.isHidden){
//                medicationTableView.isHidden = false;
            }
            
            lblMedicationCount.text = "(\(medicationCount))";
//            lblMedicationCount.isHidden = false;
        } else {
//            medicationTableView.isHidden = true;
            lblMedicationCount.text = "";
        }
    }
    
    // sort medications array
    func sortMedications() -> [Any]{
        return kid!.medications!.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]);
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
    @objc func dobDonePressed(){
        // format results
        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .medium;
        dateFormatter.timeStyle = .none;
        
        txtDOB.text = dateFormatter.string(from: dobPicker.date);
        closePicker();
        
        self.saveKidInfo();
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
    @objc func bloodTypeDonePressed(){
        txtBloodType.text = aBloodTypes[bloodTypePicker.selectedRow(inComponent: 0)];
        closePicker();
        
        self.saveKidInfo();
    }
    
    // Close all pickers
    @objc func closePicker(){
        self.view.endEditing(true);
    }
    
    // set avatar button after selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage;
        
        imgAvatar.image = Utilities.imageOrientation(image);
        imagePicker.dismiss(animated: true, completion: nil);
        self.saveKidInfo();
    }
    
    /************************/
    // MARK: - CONTACT STORE METHODS
    /************************/
    
    // execute after selection of doctor/contact
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // get context
        let context = appDelegate.persistentContainer.viewContext;
        selectedDoctorContact = DoctorContact(context: context);
        selectedDoctorContact!.contactId = contact.identifier;
        selectedDoctorContact!.kid = kid;
        selectedDoctorContact!.id = UUID().uuidString;
        
        appDelegate.saveContext();
        
        // save allergy info to cloud for kid
        cloudHelper.saveRecordInfo(record: selectedDoctorContact!, recordType: Utilities.RecordTypes.doctorContact)
        
//        doctorTableView.isHidden = false;
//        self.doctors.append(contact);
        doctorTableView.reloadData();
    }
    
    // show authorization message for Contact selector
    func showMessage(message: String){
        let alertController = UIAlertController(title: "Contacts", message: message, preferredStyle: .alert);
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: {(alert) -> Void in });
        
        alertController.addAction(dismissAction);
        
        self.present(alertController, animated: true, completion: nil);
    }
    
    // request access for Contact selection
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts);
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access);
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        //                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                        self.showMessage(message: message);
                        //                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "allergySegue"){
            let nextVC: AllergyViewController = segue.destination as! AllergyViewController;
            
            // pass kid info
            nextVC.kid = kid;
            
            // pass selected allergy
            nextVC.allergy = selectedAllergy;
        } else if(segue.identifier == "medicationSegue"){
            let nextVC: MedicationViewController = segue.destination as! MedicationViewController;
            
            // pass kid info
            nextVC.kid = kid;
            
            // pass selected medication
            nextVC.medication = selectedMedication;
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
    // MARK: - ACTIONS
    /************************/
    
    // show contact picker
    @IBAction func showContacts(_ sender: Any) {
        let contactPickerViewController = CNContactPickerViewController();
        contactPickerViewController.delegate = self;
        
        present(contactPickerViewController, animated: true, completion: nil);
    }
    
    // check to see if a kid name exists
    @IBAction func checkForName(_ sender: Any) {
        if(!txtName.text!.isEmpty){
            self.saveKidInfo();
        }
    }
    
    // save gender pick
    @IBAction func genderPicked(_ sender: Any) {
        self.saveKidInfo();
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
    
    // change/set avatar image
    @IBAction func avatarTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary;
        
        present(imagePicker, animated: true, completion: nil);
    }
    
    // delete kid
    @IBAction func deleteTapped(_ sender: Any) {
        // show activity indicator
        utilities.showActivityIndicator();
        
        let warningAlert = UIAlertController(title: "Delete \(txtName!.text!)", message: "Are you sure? This cannot be undone.", preferredStyle: .alert);
        warningAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            UIApplication.shared.beginIgnoringInteractionEvents();
            
            // delete from iCloud
            self.cloudModel.deleteType(recordToDelete: self.kid!, recordTypeToDelete: Utilities.RecordTypes.kid)
            
            // get context
            let context = self.appDelegate.persistentContainer.viewContext;
            
            // delete kid
            context.delete(self.kid!);
            
            // save context
            self.appDelegate.saveContext();
            
            // navigate back to main view
            self.navigationController?.popViewController(animated: true);
        }));
        warningAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            // hide activity indicator
            self.utilities.hideActivityIndicator();
        }));
        self.present(warningAlert, animated: true, completion: nil);
    }
}
