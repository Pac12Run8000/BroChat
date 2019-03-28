//
//  ViewController.swift
//  BroChat
//
//  Created by Michelle Grover on 3/22/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ifLoggedOutGetLoginController { (isNil) in
            if (isNil) {
                self.performSegue(withIdentifier: "segueLogin", sender: self)
            }
        }

        setupNavbar()
        backgroundAttributes()
        
    }
    
   
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        
        logoutSetUseridToNil { (isSignedOut) in
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
    
    private func logoutSetUseridToNil(handler:@escaping(_ isSignedOut:Bool) -> ()) {
        do {
            try Auth.auth().signOut()
            handler(true)
        } catch {
            handler(false)
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
