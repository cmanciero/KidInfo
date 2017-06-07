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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        kidsTableView.delegate = self;
        kidsTableView.dataSource = self;
    }
    
    // select kid
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get selected kid
        let kid = arrKids[indexPath.row];
        
        // navigate to kid info, show selected kid
        performSegue(withIdentifier: "showKidSegue", sender: kid);
        
        // deselect selected row
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    // get ready to segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showKidSegue"){
            let nextVC: KidInfoViewController = segue.destination as! KidInfoViewController;
            nextVC.kid = sender as? Kid;
        }
    }
    
    // set table row count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrKids.count;
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
    
    // get the age of kid
    func calculateAge(dob: Date) -> Int{
        let now = Date();
        let birthday: Date = dob;
        let calendar = Calendar.current;
        
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now);
        let age = ageComponents.year!;
        
        return age;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

