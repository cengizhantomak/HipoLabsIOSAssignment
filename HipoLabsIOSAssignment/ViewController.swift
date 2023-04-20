//
//  ViewController.swift
//  HipoLabsIOSAssignment
//
//  Created by Cengizhan Tomak on 15.04.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var membersTableView: UITableView!
    
    var nameArray = [String]()
    var positionArray = [String]()
    var yearsArray = [Int]()
    var githubArray = [String]()
    
    var user = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        membersTableView.delegate = self
        membersTableView.dataSource = self
        
        membersTableView.separatorStyle = .none
        membersTableView.showsVerticalScrollIndicator = false
        
        getData()
        
        jsonToCoreData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func getData() {
        
        nameArray.removeAll(keepingCapacity: false)
        positionArray.removeAll(keepingCapacity: false)
        yearsArray.removeAll(keepingCapacity: false)
        githubArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext //10)
        
        let fetchRequestMembers = NSFetchRequest<NSFetchRequestResult>(entityName: "Members")
        let fetchRequestHipo = NSFetchRequest<NSFetchRequestResult>(entityName: "Hipo")
        
        fetchRequestMembers.returnsObjectsAsFaults = false
        fetchRequestHipo.returnsObjectsAsFaults = false
        
        do {
            let resultsMembers = try context.fetch(fetchRequestMembers)
            for result in resultsMembers as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    self.nameArray.append(name)
                }
                
                if let github = result.value(forKey: "github") as? String {
                    self.githubArray.append(github)
                }
                
                self.membersTableView.reloadData()
            }
            
            let resultsHipo = try context.fetch(fetchRequestHipo)
            for result in resultsHipo as! [NSManagedObject] {
                if let position = result.value(forKey: "position") as? String {
                    self.positionArray.append(position)
                }
                
                if let years = result.value(forKey: "years") as? Int {
                    self.yearsArray.append(years)
                }
                
                self.membersTableView.reloadData()
            }
            
        } catch {
            print("error")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = membersTableView.dequeueReusableCell(withIdentifier: "memberCell") as! MembersTableViewCell
        
        let name = nameArray[indexPath.row]
        let position = positionArray[indexPath.row]
        let years = yearsArray[indexPath.row]
        
        cell.nameLabel.text = name
        cell.positionLabel.text = ("\(position)")
        cell.yearsLabel.text = String((",  \(years) years"))
        
        cell.view.layer.cornerRadius = 8
        cell.view.layer.borderWidth = 1
        cell.view.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondVC" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.user = user
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        user = githubArray[indexPath.row]
        performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequestMembers = NSFetchRequest<NSFetchRequestResult>(entityName: "Members")
            fetchRequestMembers.returnsObjectsAsFaults = false
            
            let fetchRequestHipo = NSFetchRequest<NSFetchRequestResult>(entityName: "Hipo")
            fetchRequestHipo.returnsObjectsAsFaults = false
            
            do {
                let resultsMembers = try context.fetch(fetchRequestMembers) as! [NSManagedObject]
                let resultsHipo = try context.fetch(fetchRequestHipo) as! [NSManagedObject]
                
                if let memberToDelete = resultsMembers.first {
                    context.delete(memberToDelete)
                    try context.save()
                    
                    nameArray.remove(at: indexPath.row)
                    githubArray.remove(at: indexPath.row)
                }
                
                if let hipoToDelete = resultsHipo.first {
                    context.delete(hipoToDelete)
                    try context.save()
                    
                    positionArray.remove(at: indexPath.row)
                    yearsArray.remove(at: indexPath.row)
                }
                
                membersTableView.deleteRows(at: [indexPath], with: .fade)
                membersTableView.reloadData()
                
            } catch {
                print("Error while deleting member")
            }
        }
    }
    
    @IBAction func sortMembersButton(_ sender: Any) {
        
    }
    
    //    @IBAction func addNewMemberButton(_ sender: Any) {
    //        performSegue(withIdentifier: "toAddMembersVC", sender: nil)
    //
    //    }
    
}

