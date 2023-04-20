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
    var teamArray = [String]()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func getData() {
        
        nameArray.removeAll(keepingCapacity: false)
        positionArray.removeAll(keepingCapacity: false)
        teamArray.removeAll(keepingCapacity: false)
        yearsArray.removeAll(keepingCapacity: false)
        githubArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext //10)
        
        let fetchRequestTeam = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        let fetchRequestMembers = NSFetchRequest<NSFetchRequestResult>(entityName: "Members")
        let fetchRequestHipo = NSFetchRequest<NSFetchRequestResult>(entityName: "Hipo")
        
        fetchRequestTeam.returnsObjectsAsFaults = false
        fetchRequestMembers.returnsObjectsAsFaults = false
        fetchRequestHipo.returnsObjectsAsFaults = false
        
        do {
            let resultsTeam = try context.fetch(fetchRequestTeam)
            for result in resultsTeam as! [NSManagedObject] {
                if let team = result.value(forKey: "team") as? String {
                    self.teamArray.append(team)
                }
                
                self.membersTableView.reloadData()
            }
            
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = membersTableView.dequeueReusableCell(withIdentifier: "memberCell") as! MembersTableViewCell
        
        let team = teamArray[indexPath.row]
        let name = nameArray[indexPath.row]
        let position = positionArray[indexPath.row]
        let years = yearsArray[indexPath.row]
        
        cell.teamLabel.text = team
        cell.nameLabel.text = name
        cell.positionLabel.text = position
        cell.yearsLabel.text = String(years)
        
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
            
            let fetchRequestTeam = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
            fetchRequestTeam.returnsObjectsAsFaults = false
            
            let fetchRequestMembers = NSFetchRequest<NSFetchRequestResult>(entityName: "Members")
            fetchRequestMembers.returnsObjectsAsFaults = false
            
            let fetchRequestHipo = NSFetchRequest<NSFetchRequestResult>(entityName: "Hipo")
            fetchRequestHipo.returnsObjectsAsFaults = false
            
            do {
                let resultsTeam = try context.fetch(fetchRequestTeam) as! [NSManagedObject]
                let resultsMembers = try context.fetch(fetchRequestMembers) as! [NSManagedObject]
                let resultsHipo = try context.fetch(fetchRequestHipo) as! [NSManagedObject]
                
                if let teamToDelete = resultsTeam.first {
                    context.delete(teamToDelete)
                    try context.save()
                    
                    teamArray.remove(at: indexPath.row)
                }
                
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

