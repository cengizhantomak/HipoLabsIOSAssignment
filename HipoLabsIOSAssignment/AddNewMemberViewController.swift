//
//  AddNewMemberViewController.swift
//  HipoLabsIOSAssignment
//
//  Created by Cengizhan Tomak on 19.04.2023.
//

import UIKit
import CoreData

class AddNewMemberViewController: UIViewController {
    
    @IBOutlet weak var teamView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var githubView: UIView!
    @IBOutlet weak var PositionView: UIView!
    @IBOutlet weak var YearsView: UIView!
    
    @IBOutlet weak var teamText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var githubText: UITextField!
    @IBOutlet weak var positionText: UITextField!
    @IBOutlet weak var yearsText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamView.layer.cornerRadius = 8
        nameView.layer.cornerRadius = 8
        githubView.layer.cornerRadius = 8
        PositionView.layer.cornerRadius = 8
        YearsView.layer.cornerRadius = 8
        
        teamView.layer.borderWidth = 1
        nameView.layer.borderWidth = 1
        githubView.layer.borderWidth = 1
        PositionView.layer.borderWidth = 1
        YearsView.layer.borderWidth = 1
        
        teamView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        nameView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        githubView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        PositionView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        YearsView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTeam = NSEntityDescription.insertNewObject(forEntityName: "Team", into: context)
        let newMembers = NSEntityDescription.insertNewObject(forEntityName: "Members", into: context)
        let newHipo = NSEntityDescription.insertNewObject(forEntityName: "Hipo", into: context)
        
        newTeam.setValue(teamText.text, forKey: "team")
        newMembers.setValue(nameText.text, forKey: "name")
        newMembers.setValue(githubText.text, forKey: "github")
        newHipo.setValue(positionText.text, forKey: "position")
        
        if let years = Int(yearsText.text!) {
            newHipo.setValue(years, forKey: "years")
        }
        
        do {
            try context.save()
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
