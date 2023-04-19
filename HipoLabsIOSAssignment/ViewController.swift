//
//  ViewController.swift
//  HipoLabsIOSAssignment
//
//  Created by Cengizhan Tomak on 15.04.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btn(_ sender: Any) {
        
        let user = textField.text ?? ""
        
        if user.isEmpty {
            
            let alert = UIAlertController(title: "UYARI", message: "Lütfen isim giriniz", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let vc = self.storyboard?.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
            vc.user = user
            self.show(vc, sender: nil)
            
            
            
            
            
        }
        
    }
    
}

