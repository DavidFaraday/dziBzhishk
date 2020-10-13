//
//  UsersTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    //MARK: - Vars
    var allUsers:[User] = []

    @IBOutlet weak var headerView: UIView!
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .always
        tableView.tableHeaderView = headerView
        
        downloadUsers(with: .Stable)
    }
    
    //MARK: - IBActions
    
    @IBAction func userTypeSegmentValueChanged(_ sender: UISegmentedControl) {
        
        let type: UserType = sender.selectedSegmentIndex == 0 ? .Stable : .Doctor
        downloadUsers(with: type)
    }
    

    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return allUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell

        cell.configure(user: allUsers[indexPath.row])
        
        return cell
    }
    
    //MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        showUserProfile(allUsers[indexPath.row])
    }



    
    //MARK: - Download users
    private func downloadUsers(with type: UserType) {
        
        FirebaseUserListener.shared.downloadUserType(with: type) { (allUsers) in

            self.allUsers = allUsers

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
  
    
    //MARK: - Navigation
    private func showUserProfile(_ user: User) {
        
        let profileVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileView") as! UserProfileTableViewController
        
        profileVc.user = user
        self.navigationController?.pushViewController(profileVc, animated: true)
    }

}
