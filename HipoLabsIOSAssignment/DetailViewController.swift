//
//  DetailViewController.swift
//  HipoLabsIOSAssignment
//
//  Created by Kerem Tuna Tomak on 15.04.2023.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var repo: UILabel!
    
    var user = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        github(name: user)
    }
    

    func github(name: String) {
        
        if let url = URL(string: "https://api.github.com/users/\(name)") {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    if let incomingData = data {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: incomingData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            
                            //print(json)
                            
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
