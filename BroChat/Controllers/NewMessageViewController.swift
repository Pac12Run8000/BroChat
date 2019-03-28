//
//  NewMessageViewController.swift
//  BroChat
//
//  Created by Michelle Grover on 3/28/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class NewMessageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        backgroundAttributes()
        
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
