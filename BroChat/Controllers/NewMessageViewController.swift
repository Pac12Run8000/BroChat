//
//  NewMessageViewController.swift
//  BroChat
//
//  Created by Michelle Grover on 3/28/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewMessageViewController: UIViewController {
    
    var ref:DatabaseReference?
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        backgroundAttributes()
        
        ref = Database.database().reference()
        ref?.child("users").observe(.childAdded, with: { (snapshot) in
            
            
            
            print(snapshot)

            
            
        })
    }
    
    
    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
// MARK:- UILayout attributes
extension NewMessageViewController {
    
    private func setupNavbar() {
        navigationController?.navigationBar.barTintColor = UIColor.darkPinkish
        navigationController?.navigationBar.tintColor = UIColor.lightBlue1
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.lightBlue1]
    }
    
    private func backgroundAttributes() {
        view.backgroundColor = UIColor.lightPinkish
    }
    
}

extension NewMessageViewController {
    
}
