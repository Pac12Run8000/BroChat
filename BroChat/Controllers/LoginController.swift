//
//  LoginController.swift
//  BroChat
//
//  Created by Michelle Grover on 3/22/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    @IBOutlet weak var textFieldContainerView: UIView!
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentOutlet.selectedSegmentIndex = LoginState.Login.rawValue
        setFieldsOnUI(segmentedIndex: segmentOutlet.selectedSegmentIndex)
        setviews()
        setimageView()
        
        passwordOutlet.delegate = self
        emailOutlet.delegate = self
        usernameOutlet.delegate = self
        
        
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        
        setFieldsOnUI(segmentedIndex: segmentOutlet.selectedSegmentIndex)
        

        
    }
    
    

    

}
// MARK:- UI Layout
extension LoginController {
    
    private func setimageView() {
        imageView.layer.borderColor = UIColor.customDarkBlue.cgColor
        imageView.layer.borderWidth = 4
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
    }
    
    private func setviews() {
        view.backgroundColor = UIColor.lightPinkish
        textFieldContainerView.backgroundColor = UIColor.lightPinkish
    }
    
    private func setFieldsOnUI(segmentedIndex:Int) {
        usernameOutlet.isHidden = segmentedIndex == 0 ? true : false
        imageView.isHidden = segmentedIndex == 0 ? true : false
        emailOutlet.isHidden = false
        passwordOutlet.isHidden = false
        
        if segmentedIndex == 0 {
            emailOutlet.becomeFirstResponder()
        } else {
            usernameOutlet.becomeFirstResponder()
        }
    }
    
    
}
// MARK:- Enum for the controller state - Login, Register
extension LoginController {
    
    enum LoginState: Int {
        case Login = 0
        case Register = 1
    }
    

    
}

// MARK:- UITextFieldDelegate functionality
extension LoginController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismiss(animated: true, completion: nil)
        return true
    }
}



