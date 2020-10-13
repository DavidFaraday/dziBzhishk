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
    
    //Labels
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var secretKeyLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    //TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var secretKeyTextField: UITextField!
    
    //Buttons
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    
    //Views
    @IBOutlet weak var repeatPasswordLineView: UIView!
    @IBOutlet weak var secretKeyLineView: UIView!
    
    //MARK: - Vars
    var isLogin = true

    
    
    //MARK: - View LiveCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUIForLoginType()
        setupTextFieldDelegates()
        setupBackgroundTap()
    }
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        ProgressHUD.show()
        
        if isDataInputed(for: isLogin ? .Login : .Registration) {
            
            isLogin ? loginUser() : registerUser()
        } else {
            ProgressHUD.showFailed("All fields are requires!")
            
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
        isDataInputed(for: .ForgotPassword) ? resetPassword() : ProgressHUD.showFailed("Email is requires!")
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        isDataInputed(for: .ResendVerificationMail) ? resendVerificationEmail() : ProgressHUD.showFailed("Email is requires!")
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        isLogin.toggle()
        updateUIForLoginType()
    }
    
    
    //MARK: - Login/Registration
    private func loginUser() {
        
        FirebaseAuthService.shared.loginUser(with: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            
            if error == nil {
                
                if isEmailVerified {
                    self.finishLogin()
                } else {
                    ProgressHUD.showFailed("Please verify email.")
                    
                    self.resendEmailButtonOutlet.isHidden = false
                }
                
                ProgressHUD.dismiss()
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

    private func resendVerificationEmail() {
        
        FirebaseAuthService.shared.resendVerificationEmail(to: emailTextField.text!) { (error) in
            
            if error == nil {
                ProgressHUD.showSucceed("New verification email sent.")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    } 
    
    private func resetPassword() {
        
        FirebaseAuthService.shared.resetPassword(for: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.showSucceed("Reset link sent to email.")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }


    //MARK: - Animations
    private func updateUIForLoginType() {

        self.loginButtonOutlet.setTitle(isLogin ? "Login" : "SignUp", for: .normal)
        
        self.signUpButtonOutlet.setTitle(isLogin ? "SignUp" : "Login", for: .normal)

        self.signUpLabel.text = isLogin ? "Don't have an account?" : "Have an account?"

        UIView.animate(withDuration: 0.5) { [self] in

            repeatPasswordTextField.isHidden = isLogin
            repeatPasswordLabel.isHidden = isLogin
            repeatPasswordLineView.isHidden = isLogin
            
            secretKeyLabel.isHidden = isLogin
            secretKeyTextField.isHidden = isLogin
            secretKeyLineView.isHidden = isLogin
        }
    }

    private func updatePlaceholderLabels(textField: UITextField) {

        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Password" : ""
        case repeatPasswordTextField:
            repeatPasswordLabel.text = textField.hasText ? "Repeat Password" : ""
        default:
            secretKeyLabel.text = textField.hasText ? "Secret Key" : ""
        }

    }

    //MARK: - Setup
    private func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        secretKeyTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }

    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func backgroundTap() {
        view.endEditing(false)
    }

    
    //MARK: - Helpers
    private func isDataInputed(for loginType: LoginType) -> Bool {

        switch loginType {
        case .Login:
            return emailTextField.text != "" && passwordTextField.text != ""
        case .Registration:
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != "" && passwordTextField.text == repeatPasswordTextField.text
        case .ForgotPassword, .ResendVerificationMail:
           return  emailTextField.text != ""
        }
    }
    
    //MARK: - Navigation
    private func finishLogin() {

        guard let currentUser =  User.currentUser else { return }
        
        currentUser.isOnboardingCompleted ? goToApp() : goToFinishRegistration()
        
        setUser(isOnline: true)

        if currentUser.pushId == "" {
            if let pushID = userDefaults.string(forKey: AppConstants.pushId.rawValue) {
                
                updateUserPushId(newPushId: pushID)
            }

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

