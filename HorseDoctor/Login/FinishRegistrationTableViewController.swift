//
//  FinishRegistrationTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit
import ProgressHUD
import Gallery

class FinishRegistrationTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var doneButtonOutlet: UIButton!

    //MARK: - Vars
    var gallery: GalleryController!
    var avatarImageLink = ""
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = headerView
        configureAvatarTapGesture()
    }

    //MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {

        isDataInputed() ? finishRegistration() : ProgressHUD.showError("All Fields Are Required")
    }
    
    @objc func avatarImageTap() {
        showImageGallery()
    }
    
    //MARK: - Registration
    private func finishRegistration() {
        
        if var currentUser = User.currentUser {
            
            currentUser.name = nameTextField.text!
            currentUser.address = addressTextField.text!
            currentUser.telephone = phoneNumberTextField.text!
            currentUser.mobilePhone = mobileTextField.text!
            currentUser.isOnboardingCompleted = true
            currentUser.avatarLink = avatarImageLink

            FirebaseUserListener.shared.saveUserLocally(currentUser)
            FirebaseUserListener.shared.saveUserToFireStore(currentUser)
            
            goToApp()
        }
    }

    
    //MARK: - Helpers
    private func isDataInputed() -> Bool {

        return nameTextField.text != "" && addressTextField.text != ""  && phoneNumberTextField.text != "" && mobileTextField.text != ""
    }
    
    //MARK: - Configurations
    func configureAvatarTapGesture() {
        
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarImageTap)))
    }

    
    //MARK: - Navigation
    private func goToApp() {
        
        let appView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainApp")
        
        appView.modalPresentationStyle = .fullScreen
        self.present(appView, animated: true, completion: nil)
    }
    
    //MARK: - Gallery
    private func showImageGallery() {
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(self.gallery, animated: true, completion: nil)
    }
    
    
    private func uploadAvatarImage(_ image: UIImage) {
        
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName:  User.currentId)

        
        let fileDirectory = "Avatars/" + "_" + "\(User.currentId)" + ".jpg"

        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            
            self.avatarImageLink = avatarLink ?? ""
        }
    }

}


extension FinishRegistrationTableViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            
            images.first!.resolve(completion: { (icon) in
                
                if icon != nil {
                    
                    self.uploadAvatarImage(icon!)
                    self.avatarImageView.image = icon?.circleMasked
                } else {
                    ProgressHUD.showFailed("Couldn't select Image!")
                }
            })
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
