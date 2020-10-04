//
//  EditProfileTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 02/10/2020.
//

import UIKit
import Gallery
import ProgressHUD

class EditProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextFields: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    //MARK: - Vars
    var gallery: GalleryController!
    var avatarLink = ""

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        setupUI()
        configureAvatarTapGesture()
    }

    //MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        isDataInputed() ? saveUser() : ProgressHUD.showError("All fields are required")
    }
    
    
    @objc func avatarImageTap() {
        showImageGallery()
    }

    
    private func saveUser() {
        
        guard var currentUser = User.currentUser else { return }

        currentUser.name = nameTextField.text!
        currentUser.mobilePhone = mobileTextField.text!
        currentUser.telephone = phoneTextFields.text!
        currentUser.address = addressTextField.text!
        currentUser.avatarLink = avatarLink
            
        FirebaseUserListener.shared.saveUserLocally(currentUser)
        FirebaseUserListener.shared.saveUserToFireStore(currentUser)
        
        ProgressHUD.showSuccess("User updated!")
    }

    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    //MARK: - SetupUI
    private func setupUI() {
        
        guard let currentUser = User.currentUser else { return }
        
        nameTextField.text = currentUser.name
        phoneTextFields.text = currentUser.telephone
        mobileTextField.text = currentUser.mobilePhone
        addressTextField.text = currentUser.address
        
        setAvatarImage(with: currentUser.avatarLink)
    }

    private func setAvatarImage(with link: String) {
        
        if link != "" {
            FileStorage.downloadImage(imageUrl: link) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
    //MARK: - Configurations
    func configureAvatarTapGesture() {
        
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarImageTap)))
    }

    //MARK: - Helpers
    private func isDataInputed() -> Bool {

        return nameTextField.text != "" && addressTextField.text != "" && phoneTextFields.text != "" && mobileTextField.text != ""
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
            
            self.avatarLink = avatarLink ?? ""
        }
    }

}


extension EditProfileTableViewController: GalleryControllerDelegate {
    
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
