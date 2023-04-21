//
//  ViewController.swift
//  HipoLabsIOSAssignment
//
//  Created by Cengizhan Tomak on 15.04.2023.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class ViewController: UIViewController {
    
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = appDelegate.persistentContainer.viewContext
    
    var memberList = [Members]()
    var hipoList = [Hipo]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        membersTableView.delegate = self
        membersTableView.dataSource = self
        
        membersTableView.separatorStyle = .none
        membersTableView.showsVerticalScrollIndicator = false
        
        jsonToCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMembersData()
        membersTableView.reloadData()
    }
    
    func getMembersData() {
        do {
            memberList = try context.fetch(Members.fetchRequest())
            hipoList = try context.fetch(Hipo.fetchRequest())
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let index = sender as? Int
        
        if segue.identifier == "toSecondVC" {
            let secondVC = segue.destination as! DetailViewController
            secondVC.member = memberList[index!]
        }
        
        if segue.identifier == "toEditVC" {
            let toEditVC = segue.destination as! EditMemberViewController
            toEditVC.member = memberList[index!]
        }
    }
    
    func jsonToCoreData() {
        
        guard let fileUrl = Bundle.main.url(forResource: "hipo", withExtension: "json"),
              let data = try? Data(contentsOf: fileUrl) else {
            return
        }
        
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dictionary = json as? [String: Any],
              let members = dictionary["members"] as? [[String: Any]],
              let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Members> = Members.fetchRequest()
        
        do {
            let memberData = try managedContext.fetch(fetchRequest)
            
            if memberData.count == 0 {
                
                for member in members {
                    guard let name = member["name"] as? String,
                          let github = member["github"] as? String,
                          let hipo = member["hipo"] as? [String: Any],
                          let position = hipo["position"] as? String,
                          let yearsInHipo = hipo["years_in_hipo"] as? Int
                            
                    else {
                        continue
                    }
                    
                    let teamMember = Members(context: managedContext)
                    teamMember.name = name
                    teamMember.github = github
                    
                    let teamHipo = Hipo(context: managedContext)
                    teamHipo.position = position
                    teamHipo.years = Int32(yearsInHipo)
                }
                
                do {
                    try managedContext.save()
                    
                } catch {
                    print("Error saving context: \(error)")
                }
            }
            
        } catch {
            print("Error fetching results: \(error)")
        }
    }
    
    func jsonToData() {
        
        guard let fileUrl = Bundle.main.url(forResource: "hipo", withExtension: "json"),
              let data = try? Data(contentsOf: fileUrl) else {
            return
        }
        
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dictionary = json as? [String: Any]
        else {
            return
        }
        
        guard let members = dictionary["members"] as? [[String: Any]]
        else {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Members> = Members.fetchRequest()
        
        do {
            let memberData = try managedContext.fetch(fetchRequest)
            
            if memberData.count == 0 {
                
                for member in members {
                    guard let name = member["name"] as? String,
                          let github = member["github"] as? String,
                          let hipo = member["hipo"] as? [String: Any],
                          let position = hipo["position"] as? String,
                          let yearsInHipo = hipo["years_in_hipo"] as? Int
                            
                    else {
                        continue
                    }
                    
                    let teamMember = Members(context: managedContext)
                    teamMember.name = name
                    teamMember.github = github
                    
                    let teamHipo = Hipo(context: managedContext)
                    teamHipo.position = position
                    teamHipo.years = Int32(yearsInHipo)
                }
                
                do {
                    try managedContext.save()
                    
                } catch {
                    print("Error saving context: \(error)")
                }
            }
            
        } catch {
            print("Error fetching results: \(error)")
        }
    }
    
//    @IBAction func addNewMemberButton(_ sender: Any) {
//        performSegue(withIdentifier: "toAddMembersVC", sender: nil)
//
//    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let member = memberList[indexPath.row]
        let hipo = hipoList[indexPath.row]
        
        let cell = membersTableView.dequeueReusableCell(withIdentifier: "memberCell") as! MembersTableViewCell
        
        cell.nameLabel.text = member.name
        cell.positionLabel.text = hipo.position
        cell.yearsLabel.text = String(",  \(hipo.years) years")
        
        cell.view.layer.cornerRadius = 8
        cell.view.layer.borderWidth = 1
        cell.view.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toSecondVC", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            
            let member = self.memberList[indexPath.row]
            self.context.delete(member)
            let hipo = self.hipoList[indexPath.row]
            self.context.delete(hipo)
            appDelegate.saveContext()
            
            self.getMembersData()
            
            self.membersTableView.reloadData()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            
            self.performSegue(withIdentifier: "toEditVC", sender: indexPath.row)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    
}
