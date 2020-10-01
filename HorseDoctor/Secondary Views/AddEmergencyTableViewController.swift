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
    @IBOutlet weak var horseIdTextField: UITextField!
    
    //MARK: - Vars
    var emergencyTypePicker = UIPickerView()
    var selectedEmergencyType = EmergencyType.Orthopaedic.rawValue
    
    var emergencyToEdit: EmergencyAlert?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        configureTypePickerView()
        setTextFieldDelegate()
        configureLeftBarButton()
        
        if emergencyToEdit != nil {
            setupEditView()
        }
    }

    //MARK: - IBActions
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        if isDataInputed() {
            
            emergencyToEdit != nil ? updateEmergency() : saveEmergency()

            PushNotificationService.shared.sendEmergencyPushNotification(to: .Doctor, body: descriptionTextView.text!)
            
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
    
    private func setTextFieldDelegate() {
        typeTextField.inputView = emergencyTypePicker
    }
    
    private func setupEditView() {
        titleTextField.text = emergencyToEdit!.title
        typeTextField.text = emergencyToEdit!.type
        descriptionTextView.text = emergencyToEdit!.description
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


    //MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 3 {
            print("attach image")
        }
    }
    
    //MARK: - Helpers
    private func isDataInputed() -> Bool {
        return titleTextField.text != "" && typeTextField.text != "" && descriptionTextView.text != "" && horseIdTextField.text != ""
    }

    //MARK: - Save emergency
    private func saveEmergency() {
        
        let emergency = EmergencyAlert(id: UUID().uuidString, horseId: horseIdTextField.text!, stableId: User.currentUser!.id, stableName: User.currentUser!.name, title: titleTextField.text!, type: selectedEmergencyType, description: descriptionTextView.text, mediaLink: "", isResponded: false, respondingDoctorId: "", respondingDoctorName: "", respondedDate: Date())
        
        FirebaseEmergencyAlertListener.shared.save(emergency: emergency)
        
    }

    private func updateEmergency() {
            
        emergencyToEdit!.title = titleTextField.text!
        emergencyToEdit!.type = typeTextField.text!
        emergencyToEdit!.description = descriptionTextView.text!
        
        FirebaseEmergencyAlertListener.shared.save(emergency: emergencyToEdit!)
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
