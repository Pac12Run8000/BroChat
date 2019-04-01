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
import FirebaseDatabase



class LoginController: UIViewController {
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    @IBOutlet weak var textFieldContainerView: UIView!
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestureRecognizerForImageView()
        
        setupSegmentedController()
        
        setFieldsOnUI(segmentedIndex: segmentOutlet.selectedSegmentIndex)
        setviews()
        setimageView()
        setupErrorLabel()
        
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
    
    private func setupSegmentedController() {
        segmentOutlet.selectedSegmentIndex = LoginState.Login.rawValue
        
        segmentOutlet.tintColor = UIColor.customDarkBlue
        segmentOutlet.backgroundColor = UIColor.lightPinkish
    }
    
    
    private func setupErrorLabel() {
        errorLabelOutlet.layer.masksToBounds = true
        errorLabelOutlet.layer.borderWidth = 5
        errorLabelOutlet.layer.borderColor = UIColor.customDarkBlue.cgColor
        errorLabelOutlet.textColor = UIColor.customDarkBlue
        errorLabelOutlet.layer.cornerRadius = 8
        errorLabelOutlet.alpha = 0.0
    }
    
    private func setimageView() {
        imageView.layer.borderColor = UIColor.lightBlue1.cgColor
        imageView.backgroundColor = UIColor.lightBlue2
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
    }
    
    private func setviews() {
        view.backgroundColor = UIColor.lightPinkish
        textFieldContainerView.backgroundColor = UIColor.lightPinkish
    }
    
    private func setFieldsOnUI(segmentedIndex:Int) {
        usernameOutlet.backgroundColor = UIColor.lightBlue1
        emailOutlet.backgroundColor = UIColor.lightBlue1
        passwordOutlet.backgroundColor = UIColor.lightBlue1
       
        usernameOutlet.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedString.Key.foregroundColor:UIColor.darkPinkish])
        emailOutlet.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor:UIColor.darkPinkish])
        passwordOutlet.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor:UIColor.darkPinkish])
            

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
        
        switch segmentOutlet.selectedSegmentIndex {
        case LoginState.Login.rawValue:
            print("Logging in")
            self.loginToFirebase(emailOutletText: emailOutlet, passwordOutletText: passwordOutlet)
        case LoginState.Register.rawValue:
            print("Registering")
            self.registerIntoFirebase(imageView: imageView, usernameTextField: usernameOutlet, emailTextField: emailOutlet, passwordTextField: passwordOutlet)
        default:
            print("do nothing")
        }
        

        return true
    }
}



// MARK:- Firebase Registration functionality and Login funtionality
extension LoginController {
    
    
    private func registerIntoFirebase(imageView:UIImageView, usernameTextField:UITextField, emailTextField:UITextField, passwordTextField:UITextField) {
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        guard let profileImage = imageView.image else {
            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "Add an image for your profile.")
            return
        }
        
        guard let username = usernameTextField.text, username != "", !username.isEmpty else {
            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "Enter a username.")
            return
        }
        
        guard let email = emailTextField.text, let isValidEmail = isValidEmailAddress(testStr: email) as? Bool, isValidEmail == true else {
            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "Email is not valid")
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty, password.count >= 6 else {
            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "The password needs to have 6 or more characters.")
            return
        }
        // MARK:- Authentication functionality
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            
            if (error != nil) {
                print("error:\(error?.localizedDescription)")
                return
            }
            // MARK:- Storage functionality
            let storageRef = Storage.storage().reference().child("\(NSUUID().uuidString).png")
            storageRef.putData((imageView.image?.pngData())!, metadata: nil
                , completion: { (metaData, error) in
                    if (error != nil) {
                        print("error:\(error?.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        if (err != nil) {
                            print("error:\(err?.localizedDescription)")
                            return
                        }
                        
                        guard (url?.absoluteString) != nil else {
                            print("There was an error with absolute string.")
                            return
                        }
                        
                        // MARK:- Database functionality
                        let userID = Auth.auth().currentUser?.uid as! String
                        let ref = Database.database().reference()
                        let usersRef = ref.child("users").child(userID)
                        let values = ["username": username, "email":email, "profileImageUrl":url?.absoluteString] as [String : AnyObject]
                        usersRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
                            if (error != nil) {
                                print("error:\(String(describing: error?.localizedDescription))")
                                return
                            }
                            
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.activityIndicator.stopAnimating()
                            self.dismiss(animated: true, completion: nil)
                        })
                        
                    })
                   
            })
            
            
        }
        
    }
    
    private func loginToFirebase(emailOutletText:UITextField, passwordOutletText:UITextField) {
        guard let email = emailOutletText.text, isValidEmailAddress(testStr: email) else {
            print("Email is not valid")
            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "Email is not valid")
            return
        }
        
        guard let password = passwordOutletText.text else {
            print("There is no password.")
            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "There is no password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            guard error == nil else {
                
                if let errLocalizedDescription = error?.localizedDescription {
                    print("My Error:\(errLocalizedDescription)")
                    self.displayLabelForErrors(label: self.errorLabelOutlet, msg: errLocalizedDescription)
                } else {
                    print("There was a problem wih the login.")
                    self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "There was a problem wih the login.")
                }
                
                return
            }
            
            
            guard user != nil else {
                print("Username and password do not match.")
                self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "Username and password do not match.")
                return
            }
            
            
            
            
            self.dismiss(animated: true , completion: nil)
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
                UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
                    label.alpha = 1.0
                }, completion: { (success) in
                    if (success) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
                                label.alpha = 0.0
                            }, completion: nil)
                        })
                    }
                })
            }
        }
    }
    

}

// MARK:- Profile picture functionality
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func setupGestureRecognizerForImageView() {
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageAction))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageAction() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
        
        self.usernameOutlet.becomeFirstResponder()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}















