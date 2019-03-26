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
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
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
        
        errorLabelOutlet.layer.masksToBounds = true
        errorLabelOutlet.layer.borderWidth = 5
        errorLabelOutlet.layer.borderColor = UIColor.customDarkBlue.cgColor
        errorLabelOutlet.textColor = UIColor.customDarkBlue
        errorLabelOutlet.layer.cornerRadius = 8
        errorLabelOutlet.alpha = 0.0
        
        
        
        
        
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
        
        if (segmentOutlet.selectedSegmentIndex == LoginState.Login.rawValue) {
            print("Logging in")
            

            if let email = emailOutlet.text, let password = passwordOutlet.text {
                
                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                    
                }
            }
            
            
        } else {
            print("Registering")
            
           self.sanityCheckingWithRegistrationIntoFirebase(usernameField: usernameOutlet, emailField: emailOutlet, passwordField: passwordOutlet)
            
        }
        return true
    }
}



// MARK:- Firebase Registration functionality and Login funtionality
extension LoginController {
    
    private func sanityCheckingWithRegistrationIntoFirebase(usernameField:UITextField, emailField:UITextField, passwordField:UITextField) {
        
        guard let usernameOutletText = usernameField.text, usernameOutletText != "", !usernameOutletText.isEmpty else {
            print("Enter a value for username.")
            self.displayLabelForErrors(label: errorLabelOutlet, msg: "Enter a username.")
//            self.errorLabelOutlet.text = "enter a username."
            return
        }
        
        guard let emailOutletText = emailField.text, let isValidEmail = isValidEmailAddress(testStr: emailOutletText) as? Bool, isValidEmail == true else {
            print("Email is not valid")
            self.displayLabelForErrors(label: errorLabelOutlet, msg: "Email is not valid")
//            self.errorLabelOutlet.text = "email is not valid."
            return
        }
        
        guard let passwordOutletText = passwordField.text, !passwordOutletText.isEmpty, passwordOutletText.count >= 6 else {
            print("The password needs to have 6 or more characters.")
            self.displayLabelForErrors(label: errorLabelOutlet, msg: "The password needs to have 6 or more characters.")
            return
        }
        
        registerIntoFirebase(username: usernameOutlet.text, emailAddress: emailOutlet.text, password: passwordOutlet.text!) { (success, error, name) in
            if (success!) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    private func registerIntoFirebase(username:String?, emailAddress:String?, password:String, completionHandler:@escaping(_ succeed:Bool?,_ error:Error?,_ username:String?) -> ()) {
        
        if let email = emailAddress, let password = password as? String, let username = username as? String {
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                guard error == nil else {
                    print("Error:\(String(describing: error?.localizedDescription))")
                    completionHandler(false, error, username)
                    return
                }
                completionHandler(true, nil, username)
            }
        }
    }
    
    
    
    
}


// MARK:- Field Validation Logic
extension LoginController {
    
    func isValidEmailAddress(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
   
    
 
}

// MARK: Animate the error message
extension LoginController {
    
    private func displayLabelForErrors(label:UILabel, msg:String) {
        DispatchQueue.main.async {
            label.text = "\(msg)"
        }
        fadeInfadeOut(label: label)
    }
    
    private func fadeInfadeOut(label:UILabel) {
        DispatchQueue.main.async {
            if (label.alpha == 0.0) {
                UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseIn, animations: {
                    label.alpha = 1.0
                }, completion: { (success) in
                    if (success) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseIn, animations: {
                                label.alpha = 0.0
                            }, completion: nil)
                        })
                    }
                })
            }
        }
    }
    

}















