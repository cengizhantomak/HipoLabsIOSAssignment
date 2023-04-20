//
//  DetailViewController.swift
//  HipoLabsIOSAssignment
//
//  Created by Cengizhan Tomak on 15.04.2023.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var repo: UILabel!
    @IBOutlet weak var repoTableView: UITableView!
    
    var user = String()
    
    var repoNames = [RepoDetail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repoTableView.delegate = self
        repoTableView.dataSource = self

        github(name: user)
        
        repo(name: user) {
            self.repoTableView.reloadData()
            print(self.repoNames)
        }
        
        repoTableView.allowsSelection = false
        repoTableView.separatorStyle = .none
        repoTableView.showsVerticalScrollIndicator = false
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Charter-Bold", size: 16)!]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "repoCell") as! RepoTableViewCell
        
        let repo = repoNames[indexPath.row].name
        let lang = repoNames[indexPath.row].language
        let star = repoNames[indexPath.row].stargazers_count
        let date = repoNames[indexPath.row].created_at
        
        let dateString = date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateString2 = dateFormatter.date(from: dateString!)
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let dateNew = dateFormatter.string(from: dateString2!)
        
        cell.nameLabel.text = repo
        cell.langLabel.text = lang
        cell.starLabel.text = String(star!)
        cell.dateLabel.text = dateNew
        
        cell.view.layer.cornerRadius = 8
        cell.view.layer.borderWidth = 1
        cell.view.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 235/255, alpha: 0.5).cgColor
        
        return cell
    }
    
    func repo(name: String, completed: @escaping () -> ()) {
        
        if let url = URL(string: "https://api.github.com/users/\(name)/repos") {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    
                    do {
                        self.repoNames = try JSONDecoder().decode([RepoDetail].self, from: data!)
                        DispatchQueue.main.async {
                            completed()
                        }
                        
                    }catch {
                        print("hata oluştu")
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    func github(name: String) {
        
        if let url = URL(string: "https://api.github.com/users/\(name)") {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    if let incomingData = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: incomingData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            
                            let resim = json["avatar_url"] as! String
                            if let url = URL(string: resim) {
                                DispatchQueue.global().async {
                                    let data = try? Data(contentsOf: url)
                                    DispatchQueue.main.async {
                                        self.avatar.image = UIImage(data: data!)
                                        self.avatar.layer.cornerRadius = self.avatar.bounds.width / 2
                                        self.avatar.clipsToBounds = true
                                        self.avatar.layer.borderWidth = 1.5
                                        self.avatar.layer.borderColor = UIColor.white.cgColor
                                    }
                                }
                            }
                            
                            let userName = json["name"] as! String
                            DispatchQueue.main.sync {
                                self.navigationItem.title = String(userName)
                            }
                            
                            let followers = json["followers"] as! Int
                            DispatchQueue.main.sync {
                                self.followers.text = String(followers)
                            }

                            let following = json["following"] as! Int
                            DispatchQueue.main.sync {
                                self.following.text = String(following)
                            }

                            let repo = json["public_repos"] as! Int
                            DispatchQueue.main.sync {
                                self.repo.text = String("Repositories: \(repo)")
                            }
                            
                        }catch {
                            print("hata oluştu")
                        }
                    }
                }
            }
            task.resume()
        }
    }

}
