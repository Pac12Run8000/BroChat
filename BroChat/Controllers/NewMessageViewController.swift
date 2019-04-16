//
//  NewMessageViewController.swift
//  BroChat
//
//  Created by Michelle Grover on 3/28/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth



protocol NewMessagesControllerDelegate:class {
    func dismissNewMessagePresentChatlog(_ controller:NewMessageViewController, user:User)
}

class NewMessageViewController: UIViewController {
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var timer:Timer?
    var ref:DatabaseReference?
    var users = [User]()
    var filteredUsers = [User]()
    var databaseHandle:DatabaseHandle?
    
    var messagesController:ViewController?
    
    var newMessagesControllerDelegate:NewMessagesControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarOutlet.delegate = self

        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupNavbar()
        backgroundAttributes()
        
        ref = Database.database().reference()
        databaseHandle = ref?.child("users").observe(.childAdded, with: { (snapshot) in
            self.processSnapShot(mySnapshot: snapshot)
        })
        
        tableView.separatorColor = UIColor.customDarkBlue
        
        
    }
    
   
    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

}


// MARK:- UITableviewDelegate methods
extension NewMessageViewController:UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = filteredUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomCell
        
        
       
        if let profileImageUrl = user.profileImageUrl, let url = URL(string: profileImageUrl) {
            ImageService.downloadAndCacheImage(withUrl: url) { (succees, image, error) in
                if (succees) {
                    cell?.profileImageView.image = image
                }
            }
        }
        
        cell?.userObj = user
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentUser = filteredUsers[indexPath.row]
        
        newMessagesControllerDelegate?.dismissNewMessagePresentChatlog(self, user: currentUser)

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

// MARK:- Fetch Firebase Data
extension NewMessageViewController {
    
    
    private func processSnapShot(mySnapshot:DataSnapshot) {
        
        if let user = mySnapshot.value as? [String:AnyObject], mySnapshot.key != Auth.auth().currentUser?.uid {
           
            let chatUser = User()
            chatUser.id = mySnapshot.key
            chatUser.username = user["username"] as? String
            chatUser.email = user["email"] as? String
            chatUser.profileImageUrl = user["profileImageUrl"] as? String
            self.users.append(chatUser)
        
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.callReloadOfTable), userInfo: nil, repeats: false)

        }
        
    }
    
    @objc func callReloadOfTable() {
        
        self.users.sort { (user1, user2) -> Bool in
                return user1 < user2
        }
        
        filteredUsers = users
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
// MARK:- Searchbar filtering functionality
extension NewMessageViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarOutlet.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        setFilteredUsersReloadTableView(searchText: searchText)
    }
    
    private func setFilteredUsersReloadTableView(searchText:String) {
        
        if let searchText = searchText as? String, searchText.isEmpty {
            filteredUsers = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            
            filteredUsers = users.filter({ (user) -> Bool in
                if let username = user.username {
                    return username.prefix(searchText.trimmingCharacters(in: .whitespaces).count) == searchText.trimmingCharacters(in: .whitespaces)
                }
                return false
            })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}


