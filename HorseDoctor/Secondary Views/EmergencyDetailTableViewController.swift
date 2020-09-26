//
//  EmergencyDetailTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 24/09/2020.
//

import UIKit

class EmergencyDetailTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var textViewBackgroundView: UIView!
    @IBOutlet weak var stableNameLabel: UILabel!
    @IBOutlet weak var horseIdLabel: UILabel!
    @IBOutlet weak var emergencyTitleLabel: UILabel!
    @IBOutlet weak var emergencyTypeLabel: UILabel!
    @IBOutlet weak var emergencyDateLabel: UILabel!
    @IBOutlet weak var emergencyDescriptionTextView: UITextView!
    
    var emergency: EmergencyAlert!
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        setupUI()
        setTextViewBackgroundRadius()
        configureLeftBarButton()
    }

    //MARK: - IBActions
    @IBAction func respondButtonPressed(_ sender: Any) {
        print("respond")
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    
    //MARK: - SetupUI
    private func setupUI() {
        self.title = emergency.stableName
        stableNameLabel.text = "Stable: " + emergency.stableName
        horseIdLabel.text = "Horse Id: " + emergency.horseId
        emergencyTitleLabel.text = "Title: " + emergency.title
        emergencyTypeLabel.text = "Type: " + emergency.type
        emergencyDateLabel.text = "Date: " + emergency.date!.dateTime()
        emergencyDescriptionTextView.text = emergency.description
    }
    
    private func setTextViewBackgroundRadius() {
        emergencyDescriptionTextView.layer.cornerRadius = 8
        textViewBackgroundView.layer.cornerRadius = 8
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }


    //MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }



}
