//
//  FinishRegistrationTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit
import ProgressHUD

class FinishRegistrationTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var doneButtonOutlet: UIButton!

    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = headerView
        
    }

    //MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {

        isDataInputed() ? finishRegistration() : ProgressHUD.showError("All Fields Are Required")
    }
    
    //MARK: - Registration
    private func finishRegistration() {
        
        if var currentUser = User.currentUser {
            
            currentUser.name = nameTextField.text!
            currentUser.address = addressTextField.text!
            currentUser.telephone = phoneNumberTextField.text!
            currentUser.mobilePhone = mobileTextField.text!
            currentUser.isOnboardingCompleted = true
            
            //TODO: Avatar upload

            FirebaseUserListener.shared.saveUserLocally(currentUser)
            FirebaseUserListener.shared.saveUserToFireStore(currentUser)
            
            goToApp()
        }
    }

    
    //MARK: - Helpers
    private func isDataInputed() -> Bool {

        return nameTextField.text != "" && addressTextField.text != ""  && phoneNumberTextField.text != "" && mobileTextField.text != ""
    }
    
    //MARK: - Navigation
    private func goToApp() {
        
        let appView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainApp")
        
        appView.modalPresentationStyle = .fullScreen
        self.present(appView, animated: true, completion: nil)
    }
}
