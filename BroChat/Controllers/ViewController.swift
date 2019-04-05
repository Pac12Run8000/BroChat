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
    
    var currentUser:User?
    @IBOutlet weak var tableView: UITableView!
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        setupNavbar()

        ifLoggedOutGetLoginController { (isNil) in
            if (!isNil) {
                self.getCurrentUserDictionary(handler: { (succeed, dictionary) in
                    
                })
            }
        }
        observeMessages()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ifLoggedOutGetLoginController { (isNil) in
            if (isNil) {
                self.performSegue(withIdentifier: "segueLogin", sender: self)
            } else {
                self.getCurrentUserDictionary(handler: { (succeed, dictionary) in
                    
                    if let dictionary = dictionary {
                        self.navigationItem.title = dictionary["username"] as? String
                    } else {
                        print("There was an error getting dictionary")
                    }
                    
                })
            }
        }
        
        
    }
    
   
    
    
    
    @IBAction func newMessageButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "newMsgSegue", sender: self)
    }
    
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        
        logoutSetUseridToNil { (isSignedOut, err) in
            if (isSignedOut) {
                self.performSegue(withIdentifier: "segueLogin", sender: self)
            }
        }
        
    }
    
    @IBAction func chatButtonAction(_ sender: Any) {
        currentUser = nil
        performSegue(withIdentifier: "segueChatLog", sender: self)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
// MARK:- UILayouts
extension ViewController {
    
//    private func tableViewBackgroundColor() {
//        tableView.backgroundColor = UIColor.lightPinkish
//    }
    
//    private func backgroundAttributes() {
//        view.backgroundColor = UIColor.lightPinkish
//    }
    
    private func setupNavbar() {
        navigationController?.navigationBar.barTintColor = UIColor.darkPinkish
        navigationController?.navigationBar.tintColor = UIColor.lightBlue1
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.lightBlue1]
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

// MARK:- NewMessageDelegate functionality
extension ViewController:NewMessagesControllerDelegate {
    func dismissNewMessagePresentChatlog(_ controller: NewMessageViewController, user:User) {
        
        currentUser = user
        
        
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "segueChatLog", sender: self)
        }
    }
}

// MARK:- Prepare for segue
extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newMsgSegue") {
            
            if let controller = (segue.destination as! UINavigationController).viewControllers.first as? NewMessageViewController {
                controller.newMessagesControllerDelegate = self
            }
        }
        
        if (segue.identifier == "segueChatLog") {
            let controller = segue.destination as? ChatLogController
            controller?.user = currentUser

        }
    }
    
    
}
// MARK:- TableViewDelegate and TableViewDataSource functionality
extension ViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMessage", for: indexPath) as! CustomMessageCell
       
        if let toId = message.toId {
            convertToUserObj(toId: toId) { (user) in
                if ((user) != nil) {
                    cell.userObj = user
                }
            }
        }
        
        cell.messageObj = message
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
// MARK:- Firebase functionality
extension ViewController {
    
    private func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                var message = Message()
                message = Message.returnMessageObject(dictionary: dictionary)
//                self.messages.append(message)
                
                if let toId = message.toId {
                    self.messagesDictionary[toId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    
                    self.messages.sort(by: { (msg1, msg2) -> Bool in
                        if let timestamp1 = msg1.timestamp?.intValue, let timestanmp2 = msg2.timestamp?.intValue {
                                return timestamp1 > timestanmp2
                        }
                        return false
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
           
        }, withCancel: nil)
    }
    
    
    private func convertToUserObj(toId:String, completionHandler:@escaping(_ user:User?) -> ()) {
        
        let ref = Database.database().reference().child("users").child(toId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                completionHandler(User.convertToUserObject(dictionary: dictionary))
            } else {
                completionHandler(nil)
            }
        }, withCancel: nil)
        
    }
}



