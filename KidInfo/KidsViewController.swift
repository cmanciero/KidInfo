//
//  ViewController.swift
//  KidInfo
//
//  Created by i814935 on 6/1/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class KidsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var kidsTableView: UITableView!
    
    var arrKids: [Kid] = [];
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray);
    let activityView = UIView();
    var activityViewConstraints: [NSLayoutConstraint] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        kidsTableView.delegate = self;
        kidsTableView.dataSource = self;
    }
    
    // get ready to segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showKidSegue"){
            let nextVC: KidInfoViewController = segue.destination as! KidInfoViewController;
            nextVC.kid = sender as? Kid;
        }
    }
    
    // do this everytime view appears
    override func viewWillAppear(_ animated: Bool) {
        if(UIApplication.shared.isIgnoringInteractionEvents){
            UIApplication.shared.endIgnoringInteractionEvents();
        }
        
        // get context for CoreData
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
        
        do{
            // fetch to get all kids
            arrKids = try context.fetch(Kid.fetchRequest());
            
            // reload table view
            kidsTableView.reloadData();
        } catch {}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewKidTapped(_ sender: Any) {
        self.showAddNewKidPopUp();
    }
    /************************/
    // MARK: - Functions
    /************************/
    
    // get the age of kid
    func calculateAge(dob: Date) -> Int{
        let now = Date();
        let birthday: Date = dob;
        let calendar = Calendar.current;
        
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now);
        let age = ageComponents.year!;
        
        return age;
    }
    
    func showAddNewKidPopUp() -> Void{
        // show waiting icon
        activityView.isHidden = false;
        activityIndicator.center = activityView.center;
        activityIndicator.hidesWhenStopped = true;
        activityView.addSubview(activityIndicator);
        
        // start animating
        activityIndicator.startAnimating();
        
        let newKidAlert = UIAlertController(title: "Add kid", message: "Enter the name of the kid you want to add.", preferredStyle: .alert);
        newKidAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter kid's name";
            textField.autocapitalizationType = UITextAutocapitalizationType.words;
        }
        newKidAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            UIApplication.shared.beginIgnoringInteractionEvents();
            
            if let textFields = newKidAlert.textFields{
                // get context
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
                
                let theTextFields = textFields as [UITextField];
                let kidName = theTextFields[0].text;
                let kid = Kid(context: context);
                kid.name = kidName;
                
                // save context
                (UIApplication.shared.delegate as! AppDelegate).saveContext();
                
                UIApplication.shared.endIgnoringInteractionEvents();
                
                // navigate to kid info
                self.navigateToSelectedKid(kid: kid);
            }
        }));
        newKidAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.activityIndicator.stopAnimating();
            self.activityView.isHidden = true;
        }));
        self.present(newKidAlert, animated: true, completion: nil);
    }
    
    func navigateToSelectedKid(kid: Kid) -> Void{
        // navigate to kid info, show selected kid
        performSegue(withIdentifier: "showKidSegue", sender: kid);
    }
    
    /************************/
    // MARK: - tableView methods
    /************************/
    
    // set table row count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrKids.count;
    }
    
    // select kid
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get selected kid
        let kid = arrKids[indexPath.row];
        
        // navigate to kid info, show selected kid
        self.navigateToSelectedKid(kid: kid);
        
        // deselect selected row
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    // display kids in table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kidInfoTableViewCell", for: indexPath) as! KidTableViewCell;
        let kid = arrKids[indexPath.row];
        
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
        
        return cell;
    }
}

