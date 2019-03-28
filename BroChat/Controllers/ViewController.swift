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
        
        if (Auth.auth().currentUser?.uid == nil) {
            performSegue(withIdentifier: "segueLogin", sender: self)
        }

        setupNavbar()
        backgroundAttributes()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
             performSegue(withIdentifier: "segueLogin", sender: self)
        } catch {
            print("error:\(error.localizedDescription)")
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
