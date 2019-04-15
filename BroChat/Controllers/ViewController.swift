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
import MessageUI

class ViewController: UIViewController {
    
   
    @IBOutlet weak var tableView: UITableView!
    
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    var chatUser:User?
    var currentUser:User?
    var timer:Timer?
    
    
    
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
        
        tableView.separatorColor = UIColor.customDarkBlue
        tableView.backgroundColor = UIColor.lightBlue2
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ifLoggedOutGetLoginController { (isNil) in
            if (isNil) {
                self.performSegue(withIdentifier: "segueLogin", sender: self)
            } else {
                self.getCurrentUserDictionary(handler: { (succeed, dictionary) in
                    
                    if let dictionary = dictionary {
                        self.currentUser = User.convertToUserObject(dictionary: dictionary)
                        self.navigationItem.title = self.currentUser?.username

                    } else {
                        print("There was an error getting dictionary")
                    }
                    
                })
            }
        }
        
         observeUserMessages()
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
    
//    @IBAction func chatButtonAction(_ sender: Any) {
//        chatUser = nil
//        performSegue(withIdentifier: "segueChatLog", sender: self)
//    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func inviteButtonAction(_ sender: Any) {
        composeInviteEmail()
    }
    
}
// MARK:- Mail Composing functionality
extension ViewController:MFMailComposeViewControllerDelegate {
    
    private func composeInviteEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            print("Cannot send mail.")
            return
        }
        
        // create attributed string
        guard let username = currentUser?.username else {
            print("There is no username value.")
            return
        }
        
        let myString = "You've been invited by \(username) to join the conversation on BroChat.\nFollow this link and you can get more information about this iOS application.\n Go here: https://grovertechsupport.wordpress.com"
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.blue ]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute).string
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(nil)
        composer.setSubject("Signup with BroChat")
        composer.setMessageBody(myAttrString, isHTML: false)
        present(composer, animated: true, completion: nil)
    }
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            print("Error:\(String(describing: error?.localizedDescription))")
            controller.dismiss(animated: true, completion: nil)
            return
        }
        
        switch result {
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        }
        
        controller.dismiss(animated: true , completion: nil)
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
        
        chatUser = user
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
            controller?.user = chatUser

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
        
       
       
        if let id = message.chatPartnerId() {
            convertToUserObj(toId: id) { (user) in
                if ((user) != nil) {
                    cell.userObj = user
                }
            }
        }
        
        cell.messageObj = message
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let message = messages[indexPath.row] as? Message else {
            print("There was a problem getting the message.")
            return
        }
        
        guard let myChatPartnerId = message.chatPartnerId() else {
            print("There was a problem with the ChatPartnerId")
            return
        }
        
        convertToUserObj(toId: myChatPartnerId) { (user) in
            self.chatUser = user
            self.chatUser?.id = myChatPartnerId
            
            self.performSegue(withIdentifier: "segueChatLog", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        guard let chatPartnerId = messages[indexPath.row].chatPartnerId() as? String else {
            print("There was no chatPartnerId")
            return
        }
        
        Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { (error, reference) in
            if (error != nil) {
                print("There was an error removing the data.")
                return
            }
            self.messages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
}
// MARK:- Firebase functionality
extension ViewController {
    
    private func observeUserMessages() {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
       
        guard let uid = Auth.auth().currentUser?.uid else {
            print("There is no id!")
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
               
                let messageId = snapshot.key
                self.getMessageObjectsForTableView(messageId: messageId)
                
            }, withCancel: nil)

        }, withCancel: nil)
        
    }
    
    private func getMessageObjectsForTableView(messageId:String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in

//                print(snapshot)
            if let dictionary = snapshot.value as? [String:AnyObject] {
                var message = Message()
                message = Message.returnMessageObject(dictionary: dictionary)
                //                self.messages.append(message)

                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    self.messages = Array(self.messagesDictionary.values)

                    self.messages.sort(by: { (msg1, msg2) -> Bool in
                        if let timestamp1 = msg1.timestamp?.intValue, let timestanmp2 = msg2.timestamp?.intValue {
                            return timestamp1 > timestanmp2
                        }
                        return false
                    })
                }
                    self.attemptReloadOfTable()
            }

        }, withCancel: nil)
        
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
    }
    
    
    
    @objc func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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



