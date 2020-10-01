//
//  ViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var secretKeyTextField: UITextField!
    
    //MARK: - View LiveCycle
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        isDataInputed(for: .Login) ? loginUser() : ProgressHUD.showError("Email and password is required!")
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        isDataInputed(for: .Registration) ? registerUser() : ProgressHUD.showFailed("All fields are requires!")
    }
    
    //MARK: - Login/Registration
    private func loginUser() {
        
        FirebaseAuthService.shared.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error == nil {
                
                self.finishLogin()
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func registerUser() {
        
        let type: UserType = secretKeyTextField.text == "1" ? .Doctor : .Stable
        
        FirebaseAuthService.shared.registerUserWith(with: emailTextField.text!, password: passwordTextField.text!, type: type) { (error) in
            
            if error == nil {
                
                ProgressHUD.showSuccess("Registered, please check your email and login")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }

    
    //MARK: - Helpers
    private func isDataInputed(for loginType: LoginType) -> Bool {

        switch loginType {
        case .Login:
            return emailTextField.text != "" && passwordTextField.text != ""
        case .Registration:
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != "" && passwordTextField.text == repeatPasswordTextField.text
        }
    }
    
    //MARK: - Navigation
    private func finishLogin() {
        print("finish login func")
        if let isOnboardingCompleted = User.currentUser?.isOnboardingCompleted {
            isOnboardingCompleted ? goToApp() : goToFinishRegistration()
        }
        else {
            print("no onboarding")
        }
    }
    
    private func goToApp() {
        
        let appView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainApp")
        
        appView.modalPresentationStyle = .fullScreen
        self.present(appView, animated: true, completion: nil)
    }
    
    private func goToFinishRegistration() {
        performSegue(withIdentifier: SegueType.loginToFinishRegSeg.rawValue, sender: self)
    }

}

