//
//  NewMessageViewController.swift
//  BroChat
//
//  Created by Michelle Grover on 3/28/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewMessageViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference?
    var users = [User]()
    var databaseHandle:DatabaseHandle?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = users[indexPath.row]
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
        
        if let user = mySnapshot.value as? [String:AnyObject] {

            let myUser = User()
            myUser.username = user["username"] as? String
            myUser.email = user["email"] as? String
            myUser.profileImageUrl = user["profileImageUrl"] as? String
            self.users.append(myUser)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }
        
    }
    
}
