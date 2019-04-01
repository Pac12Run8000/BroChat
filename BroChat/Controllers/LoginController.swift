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
//            self.sanityCheckingWithRegistrationIntoFirebase(usernameField: usernameOutlet, emailField: emailOutlet, passwordField: passwordOutlet)
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
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            
            if (error != nil) {
                print("error:\(error?.localizedDescription)")
                return
            }

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
                        
                        let userID = Auth.auth().currentUser?.uid as! String
                        let ref = Database.database().reference()
                        let usersRef = ref.child("users").child(userID)
                        let values = ["username":usernameTextField.text, "email":emailTextField.text, "profileImageUrl":url?.absoluteString]
                        usersRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
                            if (error != nil) {
                                print("error:\(error?.localizedDescription)")
                                return
                            }
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
    
    
    
//    private func sanityCheckingWithRegistrationIntoFirebase(usernameField:UITextField, emailField:UITextField, passwordField:UITextField) {
//
//        guard let profileImage = imageView.image, profileImage != nil else {
//            print("Add an image for your profile.")
//            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "Add an image for your profile.")
//            self.usernameOutlet.becomeFirstResponder()
//            return
//        }
//
//        guard let usernameOutletText = usernameField.text, usernameOutletText != "", !usernameOutletText.isEmpty else {
//            print("Enter a value for username.")
//            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "Enter a username.")
//            return
//        }
//
//        guard let emailOutletText = emailField.text, let isValidEmail = isValidEmailAddress(testStr: emailOutletText) as? Bool, isValidEmail == true else {
//            print("Email is not valid")
//            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "Email is not valid")
//            return
//        }
//
//        guard let passwordOutletText = passwordField.text, !passwordOutletText.isEmpty, passwordOutletText.count >= 6 else {
//            print("The password needs to have 6 or more characters.")
//            self.displayLabelForErrors(label: self.errorLabelOutlet, msg: "The password needs to have 6 or more characters.")
//            return
//        }
//
//        registerIntoFirebase(username: usernameOutletText, emailAddress:emailOutletText, password: passwordOutletText, profileImage: profileImage) { (success, error, name) in
//            if (success!) {
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//
//    }
    
    
    
//    private func registerIntoFirebase(username:String?, emailAddress:String?, password:String, profileImage:UIImage, completionHandler:@escaping(_ succeed:Bool?,_ error:Error?,_ username:String?) -> ()) {
//
//        if let email = emailAddress, let password = password as? String, let username = username as? String, let profileImage = profileImage as? UIImage {
//
//            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
//                guard error == nil else {
//                    print("Error:\(String(describing: error?.localizedDescription))")
//                    completionHandler(false, error, username)
//                    return
//                }
//
//                // MARK:- This is where storage happens ****************************
////                print("Profile Image Added:\(profileImage)")
////
//                guard let uploadData = profileImage.pngData() else {
//                    print("There was no upload data")
//                    return
//                }
//
//                guard let storageRef = self.retrieveStorageRef() else {
//                    print("Couldn't retrieve storage reference.")
//                    return
//                }
//                // MARK:- This is the image Storage function
//                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
//                    if (error != nil) {
//                        print("There was an error: \(error?.localizedDescription)")
//                        return
//                    }
//
//                    storageRef.downloadURL(completion: { (url, error) in
//                    if (error != nil) {
//                        print("couldn't get downoad url")
//                        return
//                    }
//
////                    print("url:\(url?.absoluteString)")
//
//
//                })
//
//                })
//                // ****************************************************************
//
//                self.storeUserDataIntoFirebaseDatabase(usernameStr: username, emailStr: email, completionHandler: { (succeed, err) in
//                    if (succeed) {
//                        print("Information was saved to Firebase database")
//                    }
//                })
//
//
//
//                completionHandler(true, nil, username)
//            }
//        }
//    }
    
//    private func storeUserDataIntoFirebaseDatabase(usernameStr:String, emailStr:String, completionHandler:@escaping (_ success:Bool, _ er:Error?) -> ()) {
//
//        guard let userID = Auth.auth().currentUser?.uid else {
//            print("There was an error getting the userId")
//            return
//        }
//
//        let ref = Database.database().reference()
//        let usersReference = ref.child("users").child(userID)
//        let values = ["username":usernameStr, "email":emailStr]
//        usersReference.updateChildValues(values, withCompletionBlock: { (err, reference) in
//            guard err == nil else {
//                print("Error saving to Firebase Database.")
//                completionHandler(false, err)
//                return
//            }
//            completionHandler(true, nil)
//
//
//        })
//    }
    
    
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
    

    
//    private func retrieveStorageRef() -> StorageReference? {
//        let uniqueImageName = self.generateUniqueFilename(type: .PNG)
//        return Storage.storage().reference().child("\(uniqueImageName)")
//    }
//
//    enum FileType:String {
//        case PNG = ".png"
//        case JPG = ".jpg"
//    }
//
//    private func generateUniqueFilename(type:FileType) -> String {
//        return "\(NSUUID().uuidString)\(type.rawValue)"
//    }
    
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















