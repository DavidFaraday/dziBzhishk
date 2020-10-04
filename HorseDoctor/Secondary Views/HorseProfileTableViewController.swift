//
//  HorseProfileTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 01/10/2020.
//

import UIKit

class HorseProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var chipIdTextField: UITextField!
    @IBOutlet weak var socialSecurityTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var vaccineTextField: UITextField!
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var neuteredSwitchOutlet: UISwitch!
    
    //MARK: - Vars
    var horseToDisplay: Horse?
    var horseId: String?
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Profile"
        if horseId != nil {
            downloadHorse()
        }
    }

    //MARK: - DownloadHorse
    private func downloadHorse() {
        
        FirebaseHorseListener.shared.downloadHorse(with: horseId!) { (horse) in
            
            self.horseToDisplay = horse
            
            DispatchQueue.main.async {
                self.setupUI()
            }
        }
    }

    
    //MARK: - SetupUI
    private func setupUI() {
        nameTextField.text = horseToDisplay!.name
        chipIdTextField.text = horseToDisplay!.chipId
        socialSecurityTextField.text = horseToDisplay!.socialSecurityNumber
        sexTextField.text = horseToDisplay!.isMale ? "Male" : "Female"
        //TODO: Vaccine
        vaccineTextField.text = ""
        dateOfBirthPicker.setDate(horseToDisplay!.dateOfBirth, animated: false)
        notesTextView.text = horseToDisplay!.notes
        neuteredSwitchOutlet.isOn = horseToDisplay!.neutered
        
        if horseToDisplay!.avatarLink != "" {
            FileStorage.downloadImage(imageUrl: horseToDisplay!.avatarLink) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }
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
}
