//
//  ProfileTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit
import ProgressHUD

class ProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobilePhoneLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var availableSwitchOutlet: UISwitch!
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }

    
    //MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 10.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == IndexPath(row: 0, section: 0) {
            performSegue(withIdentifier: SegueType.profileToEditProfileSeg.rawValue, sender: self)
        } else if indexPath == IndexPath(row: 0, section: 1) && User.currentUser!.userType == .Stable {
            performSegue(withIdentifier: SegueType.profileToHorsesSeg.rawValue, sender: self)
        }
    }

    
    //MARK: - IBActions
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        ProgressHUD.show()
        
        FirebaseAuthService.shared.prepareForLogOut { (readyToLogOut) in
            
            if readyToLogOut {
                FirebaseAuthService.shared.logOutCurrentUser { (error) in
                    
                    if error == nil {
                        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")

                        DispatchQueue.main.async {
                            loginView.modalPresentationStyle = .fullScreen
                            self.present(loginView, animated: true, completion: nil)
                        }
                    }
                }

            } else {
                ProgressHUD.showError("Couldn't logout")
            }
        }
        
    }
    
    @IBAction func availableSwitchValueChanged(_ sender: UISwitch) {
        
        guard var user = User.currentUser else {
            return
        }
        
        user.isAvailable = sender.isOn
        
        FirebaseUserListener.shared.saveUserLocally(user)
        FirebaseUserListener.shared.saveUserToFireStore(user)
    }
    
    
    
    //MARK: - Update UI
    private func showUserInfo() {
        if let user = User.currentUser {
            nameLabel.text = user.name
            mobilePhoneLabel.text = "Mobile " + user.mobilePhone
            appVersionLabel.text = "App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            availableSwitchOutlet.isOn = user.isAvailable ?? false
            
            if user.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }

}
