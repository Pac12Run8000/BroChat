//
//  LoginController.swift
//  BroChat
//
//  Created by Michelle Grover on 3/22/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

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
        imageView.layer.borderWidth = 1
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
        
        if IsLoginElse(input: segmentOutlet.selectedSegmentIndex) {
            print("Logging in")
            

            if let email = emailOutlet.text, let password = passwordOutlet.text {
                
                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                    
                }
            }
            
            
        } else {
            print("Registering")


            if let email = emailOutlet.text, let password = passwordOutlet.text, let username = usernameOutlet.text {
                
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    
                    
                    guard error == nil else {
                        print("error:\(error?.localizedDescription)")
                        return
                    }
                }
            }
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
        return true
    }
}


// MARK:- Logic that marks whether Login or Register
extension LoginController {
    
    private func IsLoginElse(input:Int) -> Bool {
        return input == 0 ? true : false
    }
    
    //function to check if an email is valid or not. returns true if email is valid, false if email is invalid
     func isValidEmailAddress(emailAddressString: String) -> Bool {
        var returnValue = true
        
        //regular expresion to define the format for email.
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            
            //compare the entered email by the defined format of email.
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            //if format is wrong, then return false
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            //error while matching the format & email.
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
}



