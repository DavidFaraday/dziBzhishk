//
//  UsersTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit

class UsersTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var userSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    
    //MARK: - Vars
    var allOwners:[User] = []
    var allDoctors:[User] = []

    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = headerView
        navigationItem.largeTitleDisplayMode = .always
        
        downloadOwnerUsers()
        downloadDoctors()
    }

    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return userSegmentOutlet.selectedSegmentIndex == 0 ? allOwners.count : allDoctors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell

        userSegmentOutlet.selectedSegmentIndex == 0 ? cell.configure(user: allOwners[indexPath.row]) : cell.configure(user: allDoctors[indexPath.row])

        return cell
    }
    
    //MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = userSegmentOutlet.selectedSegmentIndex == 0 ? allOwners[indexPath.row] : allDoctors[indexPath.row]

        showUserProfile(user)
    }



    
    //MARK: - Download users
    private func downloadOwnerUsers() {
        FirebaseUserListener.shared.downloadUserType(with: UserType.Owner) { (allOwners) in

            self.allOwners = allOwners

            if self.userSegmentOutlet.selectedSegmentIndex == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func downloadDoctors() {
        
        FirebaseUserListener.shared.downloadUserType(with: UserType.Doctor) { (allDoctors) in

            self.allDoctors = allDoctors

            if self.userSegmentOutlet.selectedSegmentIndex == 1 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func userSegmentValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    
    //MARK: - Navigation
    private func showUserProfile(_ user: User) {
        let profileVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileView") as! UserProfileTableViewController
        
        profileVc.user = user
        self.navigationController?.pushViewController(profileVc, animated: true)
    }

}
