//
//  AddEmergencyTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 23/09/2020.
//

import UIKit
import ProgressHUD

class AddEmergencyTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionBackgroundView: UIView!
    @IBOutlet weak var horseChipIdLabel: UILabel!
    @IBOutlet weak var respondedDoctorNameLabel: UILabel!
    
    //MARK: - Vars
    var emergencyTypePicker = UIPickerView()
    var selectedEmergencyType = EmergencyType.Orthopaedic.rawValue
    
    var emergencyToEdit: EmergencyAlert?
    var selectedHorseId = ""
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        configureTypePickerView()
        setTextFieldInputView()
        configureLeftBarButton()
        configureHorseChipLabelTap()
        
        if emergencyToEdit != nil {
            setupEditView()
        }
    }

    //MARK: - IBActions
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        if isDataInputed() {
            
            emergencyToEdit != nil ? updateEmergency() : saveEmergency()

            
            navigationController?.popViewController(animated: true)
        } else {
            ProgressHUD.showError("All Fields Are Required!")
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    @objc func doneClicked() {
        selectedEmergencyType = EmergencyType.allCases[emergencyTypePicker.selectedRow(inComponent: 0)].rawValue
        typeTextField.text = selectedEmergencyType
        dismissKeyboard()
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    
    //MARK: - SetupUI
    private func setTextViewBackgroundRadius() {
        descriptionBackgroundView.layer.cornerRadius = 8
        descriptionTextView.layer.cornerRadius = 8
    }
    
    private func setTextFieldInputView() {
        typeTextField.inputView = emergencyTypePicker
    }
    
    private func setupEditView() {
        
        self.title = "Edit Emergency"
        titleTextField.text = emergencyToEdit!.title
        typeTextField.text = emergencyToEdit!.type
        descriptionTextView.text = emergencyToEdit!.description
        selectedHorseId = emergencyToEdit!.horseId
        horseChipIdLabel.text = emergencyToEdit!.horseChipId
        
        respondedDoctorNameLabel.text = emergencyToEdit!.isResponded ? "Responded by \(emergencyToEdit!.respondingDoctorName)" : "No response"
    }
    
    //MARK: -  Configuration
    private func configureTypePickerView() {
        
        emergencyTypePicker.dataSource = self
        emergencyTypePicker.delegate = self
        
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

        typeTextField.inputAccessoryView = toolBar

    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    private func configureHorseChipLabelTap() {
        horseChipIdLabel.isUserInteractionEnabled = true
        horseChipIdLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSelectHorseView)))
    }


    //MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 2:
            showSelectHorseView()
        case 3:
            if emergencyToEdit != nil && emergencyToEdit!.isResponded {
                showUserProfile(with: emergencyToEdit!.respondingDoctorId)
            }
        case 4:
            print("attach image")
        default:
            return
        }
    }
    
    //MARK: - Helpers
    private func isDataInputed() -> Bool {
        return titleTextField.text != "" && typeTextField.text != "" && descriptionTextView.text != "" && selectedHorseId != ""
    }

    //MARK: - Save emergency
    private func saveEmergency() {
        
        let emergency = EmergencyAlert(id: UUID().uuidString, horseId: selectedHorseId, horseChipId: horseChipIdLabel.text!, stableId: User.currentUser!.id, stableName: User.currentUser!.name, title: titleTextField.text!, type: selectedEmergencyType, description: descriptionTextView.text, mediaLink: "", isResponded: false, respondingDoctorId: "", respondingDoctorName: "", respondedDate: Date())
        
        FirebaseEmergencyAlertListener.shared.save(emergency: emergency)
        
        PushNotificationService.shared.sendEmergencyPushNotification(to: .Doctor, body: descriptionTextView.text!, emergencyId: emergency.id)
    }

    private func updateEmergency() {
            
        emergencyToEdit!.title = titleTextField.text!
        emergencyToEdit!.type = typeTextField.text!
        emergencyToEdit!.description = descriptionTextView.text!
        emergencyToEdit!.horseId = selectedHorseId
        emergencyToEdit!.horseChipId = horseChipIdLabel.text!
        
        FirebaseEmergencyAlertListener.shared.save(emergency: emergencyToEdit!)
    }
    
    //MARK: - Navigation
    @objc private func showSelectHorseView() {
        
        let horseView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "allHorsesView") as! AllHorsesTableViewController
        horseView.delegate = self
        horseView.selectedHorseId = horseChipIdLabel.text
        
        navigationController?.pushViewController(horseView, animated: true)
    }
    
    private func showUserProfile(with userId: String) {
        
        let profileVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileView") as! UserProfileTableViewController
        
        profileVc.userId = userId
        
        self.navigationController?.pushViewController(profileVc, animated: true)
    }

}

extension AddEmergencyTableViewController: AllHorsesTableViewControllerDelegate {
    
    func didSelect(horse: Horse) {
        self.horseChipIdLabel.text = horse.chipId
        self.selectedHorseId = horse.id
    }
}


extension AddEmergencyTableViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView,
                didSelectRow row: Int,
                inComponent component: Int) {

        selectedEmergencyType = EmergencyType.allCases[row].rawValue
        typeTextField.text = selectedEmergencyType
    }
}

extension AddEmergencyTableViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EmergencyType.allCases.count

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return EmergencyType.allCases[row].rawValue
    }
    
}
