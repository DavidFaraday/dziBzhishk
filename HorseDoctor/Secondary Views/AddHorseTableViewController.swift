//
//  AddHorseTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 02/10/2020.
//

import UIKit
import Gallery
import ProgressHUD

protocol AddHorseTableViewControllerDelegate {
    func didFinishAddingHorse()
}

class AddHorseTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var chipIdTextField: UITextField!
    @IBOutlet weak var socialSecurityTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var vaccineTextField: UITextField!
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    @IBOutlet weak var neuteredSwitch: UISwitch!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    //MARK: - Vars
    var gallery: GalleryController!
    var sexPicker = UIPickerView()

    let horseId = UUID().uuidString
    var avatarLink = ""
    var isMale = true
    var selectedSex = "Male"
    
    var horseToEdit: Horse?
    
    var delegate: AddHorseTableViewControllerDelegate?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        configureAvatarTapGesture()
        configureSexPickerView()
        setTextFieldInputView()
        configureLeftBarButton()

        if horseToEdit != nil {
            setupEditView()
        }
    }

    
    //MARK: - IBAction
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if isDataInputed() {
            horseToEdit != nil ? updateHorse() : createHorse()
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    
    @objc func avatarImageTap() {
        showImageGallery()
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    @objc func doneClicked() {
        isMale = sexPicker.selectedRow(inComponent: 0) == 0
        selectedSex = HorseSex.allCases[sexPicker.selectedRow(inComponent: 0)].rawValue
        sexTextField.text = selectedSex
        dismissKeyboard()
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
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

    
    //MARK: - Configurations
    func configureAvatarTapGesture() {
        
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarImageTap)))
    }

    private func setTextFieldInputView() {
        sexTextField.inputView = sexPicker
    }
    
    private func configureSexPickerView() {
        
        sexPicker.dataSource = self
        sexPicker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClicked))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true

        sexTextField.inputAccessoryView = toolBar

    }

    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }

    private func setupEditView() {
        
        nameTextField.text = horseToEdit!.name
        chipIdTextField.text = horseToEdit!.chipId
        socialSecurityTextField.text = horseToEdit!.socialSecurityNumber
        sexTextField.text = horseToEdit!.isMale ? "Male" : "Female"
        isMale = horseToEdit!.isMale
        avatarLink = horseToEdit!.avatarLink
        
        dateOfBirthPicker.setDate(horseToEdit!.dateOfBirth, animated: false)
        neuteredSwitch.isOn = horseToEdit!.neutered
        notesTextView.text = horseToEdit!.notes
        
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }
    }



    //MARK: - Helpers
    private func isDataInputed() -> Bool {

        return nameTextField.text != "" && chipIdTextField.text != "" && socialSecurityTextField.text != "" && sexTextField.text != ""
    }
    
    
    //MARK: - Saving
    private func createHorse() {

        let horse = Horse(id: horseId, stableId: User.currentId, name: nameTextField.text!, chipId: chipIdTextField.text!, avatarLink: avatarLink, dateOfBirth: dateOfBirthPicker.date, neutered: neuteredSwitch.isOn, socialSecurityNumber: socialSecurityTextField.text!, vaccineIds: [""], notes: notesTextView.text, isMale: isMale)
        //TODO: vaccine

        FirebaseHorseListener.shared.saveHorse(horse)
        ProgressHUD.showSuccess("Horse created")
        
        delegate?.didFinishAddingHorse()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updateHorse() {

        horseToEdit!.name = nameTextField.text!
        horseToEdit!.chipId = chipIdTextField.text!
        horseToEdit!.socialSecurityNumber = socialSecurityTextField.text!
        horseToEdit!.isMale = isMale
        //TODO: vaccine
        horseToEdit!.vaccineIds = [""]
        horseToEdit!.dateOfBirth = dateOfBirthPicker.date
        horseToEdit!.neutered = neuteredSwitch.isOn
        horseToEdit!.notes = notesTextView.text!
        horseToEdit!.avatarLink = avatarLink
        
        FirebaseHorseListener.shared.saveHorse(horseToEdit!)
        ProgressHUD.showSuccess("Horse updated")
        
        delegate?.didFinishAddingHorse()
        self.navigationController?.popViewController(animated: true)
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
        
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName:  horseId)

        
        let fileDirectory = "Horses/" + "_" + "\(horseId)" + ".jpg"

        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            
            self.avatarLink = avatarLink ?? ""
        }
    }


}


extension AddHorseTableViewController: GalleryControllerDelegate {
    
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



extension AddHorseTableViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView,
                didSelectRow row: Int,
                inComponent component: Int) {
        
        isMale = row == 0
        selectedSex = HorseSex.allCases[row].rawValue
        sexTextField.text = selectedSex
    }
}

extension AddHorseTableViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return HorseSex.allCases.count

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return HorseSex.allCases[row].rawValue
    }
    
}
