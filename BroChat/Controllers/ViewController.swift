//
//  ViewController.swift
//  BroChat
//
//  Created by Michelle Grover on 3/22/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavbar()
        backgroundAttributes()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ifLoggedOutGetLoginController { (isNil) in
            if (isNil) {
                self.performSegue(withIdentifier: "segueLogin", sender: self)
            } else {
                self.getCurrentUserDictionary(handler: { (succeed, dictionary) in
                    self.navigationItem.title = dictionary!["username"] as? String
                })
            }
        }
    }
    
    
    
   
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        
        logoutSetUseridToNil { (isSignedOut, err) in
            if (isSignedOut) {
                self.performSegue(withIdentifier: "segueLogin", sender: self)
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
// MARK:- UILayouts
extension ViewController {
    
    
    private func setupNavbar() {
        navigationController?.navigationBar.barTintColor = UIColor.darkPinkish
        navigationController?.navigationBar.tintColor = UIColor.lightBlue1
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.lightBlue1]
    }
    
    private func backgroundAttributes() {
        view.backgroundColor = UIColor.lightPinkish
    }
    
}
// MARK:- Logout functionality
extension ViewController {
    
    private func getCurrentUserDictionary(handler:@escaping(_ success:Bool,_ dictionary:[String:AnyObject]?) ->()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("There was an error getting userId")
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                handler(true, dictionary)
            } else {
                handler(false, nil)
            }
            
        }, withCancel: nil)
        
    }
    
    private func logoutSetUseridToNil(handler:@escaping(_ isSignedOut:Bool,_ error:Error?) -> ()) {
        do {
            try Auth.auth().signOut()
            handler(true, nil)
        } catch {
            handler(false, error)
            print("error:\(error.localizedDescription)")
        }
    }
    
    
    private func ifLoggedOutGetLoginController(handler:@escaping(_ isUseridNil:Bool) -> ()) {
        if (Auth.auth().currentUser?.uid == nil) {
            handler(true)
        } else {
            handler(false)
        }
    }
}
