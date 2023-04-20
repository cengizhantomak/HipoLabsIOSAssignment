//
//  AddNewMemberViewController.swift
//  HipoLabsIOSAssignment
//
//  Created by Cengizhan Tomak on 19.04.2023.
//

import UIKit
import CoreData

class AddNewMemberViewController: UIViewController {
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var githubView: UIView!
    @IBOutlet weak var PositionView: UIView!
    @IBOutlet weak var YearsView: UIView!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var githubText: UITextField!
    @IBOutlet weak var positionText: UITextField!
    @IBOutlet weak var yearsText: UITextField!
    
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameView.layer.cornerRadius = 8
        githubView.layer.cornerRadius = 8
        PositionView.layer.cornerRadius = 8
        YearsView.layer.cornerRadius = 8
        
        nameView.layer.borderWidth = 1
        githubView.layer.borderWidth = 1
        PositionView.layer.borderWidth = 1
        YearsView.layer.borderWidth = 1
        
        nameView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        githubView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        PositionView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        YearsView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        nameText.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        githubText.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        positionText.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        yearsText.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        addButtonOutlet.isEnabled = false
    }
    
    @objc func textFieldDidChange() {
        
        guard let name = nameText.text, !name.isEmpty, let github = githubText.text, !github.isEmpty, let position = positionText.text, !position.isEmpty, let years = yearsText.text, !years.isEmpty else {
            addButtonOutlet.isEnabled = false
            return
        }
        addButtonOutlet.isEnabled = true
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        guard Int(yearsText.text!) != nil else {
            showAlert(title: "Error", message: "Please enter a valid number for years.")
            return
        }
        
        guard let githubUser = githubText.text, !githubUser.isEmpty else {
            showAlert(title: "Error", message: "Please enter GitHub username.")
            return
        }
        
        let urlString = "https://api.github.com/users/\(githubUser)"
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid URL.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data, error == nil else {
                self.showAlert(title: "Error", message: "No data received.")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(MyResponse.self, from: data)
                
                if result.login.lowercased() == githubUser.lowercased() {
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context = appDelegate.persistentContainer.viewContext
                        
                        let newMembers = NSEntityDescription.insertNewObject(forEntityName: "Members", into: context)
                        let newHipo = NSEntityDescription.insertNewObject(forEntityName: "Hipo", into: context)
                        
                        newMembers.setValue(self.githubText.text, forKey: "github")
                        newHipo.setValue(self.positionText.text, forKey: "position")
                        
                        if let years = Int(self.yearsText.text!) {
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
                    
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Username does not match.")
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Username not found.")
                }
            }
        }
        task.resume()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    struct MyResponse: Codable {
        let login: String
    }
    
}
