//
//  ViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/1/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class KidsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CloudHelperDelegate {
    
    @IBOutlet weak var kidsTableView: UITableView!
    @IBOutlet weak var noKidView: UIView!
    @IBOutlet weak var btnTapKid: UIButton!
    
    var arrKids: [Kid] = [];
    var context: NSManagedObjectContext!
    let utilities = Utilities();
    let appDelegate = Utilities.getApplicationDelegate()
    let cloudModel:CloudHelper = CloudHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // get context for CoreData
        context = appDelegate.persistentContainer.viewContext;
        
        kidsTableView.delegate = self;
        kidsTableView.dataSource = self;
        
        // create activity view
        utilities.createActivityView(view: self.view);
        
        // check local timestamp
        utilities.getTimeStamp()
        
        // make calls to iCloud
        cloudModel.delegate = self
        
        // check iCloud timestamp
        cloudModel.getTimeStamp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get kids
        getKids()
    }
    
    // get ready to segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showKidSegue"){
            let nextVC: KidInfoViewController = segue.destination as! KidInfoViewController;
            nextVC.kid = sender as? Kid;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewKidTapped(_ sender: Any) {
        self.showAddNewKidPopUp();
    }
    
    /************************/
    // MARK: - CloudHelper Delegate Methods
    /************************/
    
    func errorUpdating(error: NSError) {
        print(error)
    }
    
    func modelUpdated(results: [CKRecord]) {
        if let cloudTimeStamp = cloudModel.timeStamp {
            if cloudTimeStamp > utilities.localTimeStamp!{
                // remove all kids
                arrKids.removeAll()
                
                // check to see if results exists on iCloud
                if !results.isEmpty {
                    // loop through results and add kids to list
                    for (_, value) in results.enumerated(){
                        let newKid: Kid = Kid(context: self.context)
                        
                        newKid.name = value["name"] as? String
                        newKid.bloodType = value["bloodType"] as? String
                        newKid.dob = value["dob"] as? Date
                        newKid.gender = value["gender"] as? String
                        newKid.id = value["id"] as? String
                        print(value)
                        print(value["avatar"])
                        newKid.avatar = value["avatar"] as? Data
                        
                        arrKids.append(newKid)
                    }
                    
                    kidsTableView.reloadData()
                }
            }
        }
    }
    
    /************************/
    // MARK: - Functions
    /************************/
    
    func getKids(){
        utilities.showActivityIndicator()
        
        // check cloud kids
        cloudModel.getKids()
        
        // check local storage
        getKidsLocal()
    }
    
    // check Core Data for kids locally
    func getKidsLocal(){
        do{
            // fetch to get all kids
            arrKids = try context.fetch(Kid.fetchRequest());
            
            // reload table view
            kidsTableView.reloadData();
            
            utilities.hideActivityIndicator()
            UIApplication.shared.endIgnoringInteractionEvents();
        } catch {}
    }
    
    // get the age of kid
    func calculateAge(dob: Date) -> Int{
        let now = Date();
        let birthday: Date = dob;
        let calendar = Calendar.current;
        
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now);
        let age = ageComponents.year!;
        
        return age;
    }
    
    // display popup to add new kid
    func showAddNewKidPopUp() -> Void{
        // show activity indicator
        utilities.showActivityIndicator();
        
        let newKidAlert = UIAlertController(title: "Add kid", message: nil, preferredStyle: .alert);
        newKidAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter kid's name";
            textField.autocapitalizationType = UITextAutocapitalizationType.words;
        }
        newKidAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            UIApplication.shared.beginIgnoringInteractionEvents();
            
            if let textFields = newKidAlert.textFields{
                let theTextFields = textFields as [UITextField];
                let kidName = theTextFields[0].text;
                let kid = Kid(context: self.context);
                kid.id = UUID().uuidString;
                kid.name = kidName;
                
                // save kid to iCloud
                self.cloudModel.saveRecordInfo(record: kid, recordType: Utilities.RecordTypes.kid);
                
                // save context
                self.appDelegate.saveContext();
                
                self.utilities.hideActivityIndicator();
                UIApplication.shared.endIgnoringInteractionEvents();
                
                // navigate to kid info
                self.navigateToSelectedKid(kid: kid);
                
                // update time stamp
                self.utilities.updateTimeStamp()
            }
        }));
        newKidAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // hide activity indicator
            self.utilities.hideActivityIndicator();
        }));
        self.present(newKidAlert, animated: true, completion: nil);
    }
    
    // navigate to selected kid
    func navigateToSelectedKid(kid: Kid) -> Void{
        // navigate to kid info, show selected kid
        performSegue(withIdentifier: "showKidSegue", sender: kid);
    }
    
    // sort kids array
    func sortKids() -> [Any]{
        var arrSortedKids: [Any] = [];
        var bDOBExists = false;
        
        // check if all kids have DOB entered,
        for (_, kid) in arrKids.enumerated(){
            if(kid.dob != nil){
                bDOBExists = true;
            } else {
                bDOBExists = false;
                break;
            }
        }
        // if DOB exists then sort by DOB
        if(bDOBExists){
            arrSortedKids = arrKids.sorted(by: {$0.dob! < $1.dob!})
        } else {
            arrSortedKids = arrKids;
        }
        
        return arrSortedKids;
    }
    
    /************************/
    // MARK: - TABLEVIEW METHODS
    /************************/
    
    // set table row count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0;
        if(section == 0){
            count = arrKids.count;
        } else if(section == 1){
            count = 1;
        }
        
        return count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    // select kid
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            // get selected kid
            let sortedKids = sortKids();
            let kid = (sortedKids as! [Kid])[indexPath.row] as Kid;
            
            // navigate to kid info, show selected kid
            self.navigateToSelectedKid(kid: kid);
            
            // deselect selected row
            tableView.deselectRow(at: indexPath, animated: true);
        } else if(indexPath.section == 1){
            showAddNewKidPopUp();
        }
    }
    
    // display kids in table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var kidCell:UITableViewCell = UITableViewCell();
        
        if(indexPath.section == 0){
            let sortedKids = sortKids();
            let kid = (sortedKids as! [Kid])[indexPath.row] as Kid;
            let cell = tableView.dequeueReusableCell(withIdentifier: "kidInfoTableViewCell", for: indexPath) as! KidTableViewCell;
            
            // set kid name
            cell.lblName.text = kid.name;
            
            // set kid DOB
            let dateFormatter = DateFormatter();
            dateFormatter.dateStyle = .medium;
            dateFormatter.timeStyle = .none;
            if(kid.dob != nil){
                let formatDOB = dateFormatter.string(from: kid.dob! as Date);
                let currentAge = calculateAge(dob: kid.dob! as Date);
                cell.lblDOB.text = "\(formatDOB) (\(currentAge) years old)";
            } else {
                cell.lblDOB.text = "";
            }
            
            // check if avatar exists
            if(kid.avatar != nil){
                cell.avatarImageView?.image = UIImage(data: kid.avatar! as Data);
            }
            
            kidCell = cell
            
        } else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "addKidTableViewCell", for: indexPath) as! AddKidTableViewCell;
            
            kidCell = cell;
        }
        
        return kidCell;
    }
}

