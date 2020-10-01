//
//  EmergencyDetailTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 24/09/2020.
//

import UIKit

class EmergencyDetailTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var respondButtonOutlet: UIButton!
    @IBOutlet weak var stableNameLabel: UILabel!
    @IBOutlet weak var horseIdLabel: UILabel!
    @IBOutlet weak var emergencyTitleLabel: UILabel!
    @IBOutlet weak var emergencyTypeLabel: UILabel!
    @IBOutlet weak var emergencyDateLabel: UILabel!
    @IBOutlet weak var textViewBackgroundView: UIView!
    @IBOutlet weak var emergencyDescriptionTextView: UITextView!

    //MARK: - Vars
    var emergency: EmergencyAlert!
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        setupUI()
        setTextViewBackgroundRadius()
        configureLeftBarButton()
        updateRespondButtonStatus()
    }

    //MARK: - IBActions
    @IBAction func respondButtonPressed(_ sender: Any) {
        
        emergency.isResponded = true
        emergency.respondingDoctorId = User.currentId
        emergency.respondingDoctorName = User.currentUser?.name ?? "Unknown"
        emergency.respondedDate = Date()
        
        PushNotificationService.shared.sendPushNotificationTo(userIds: [emergency.stableId], body: "Your emergency is accepted, the doctor will contact you.")
        
        FirebaseEmergencyAlertListener.shared.save(emergency: emergency)
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func contactStableButtonPressed(_ sender: Any) {
        
        openChatRoom(with: emergency.stableId)
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
    
    private func updateRespondButtonStatus() {
        respondButtonOutlet.isEnabled = !emergency.isResponded
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == IndexPath(item: 0, section: 0) {
            showStableProfile(with: emergency.stableId)
        } else if indexPath == IndexPath(item: 1, section: 0) {
            showHorseProfile(with: emergency.horseId)
        }
    }

    //MARK: - StartChat
    private func openChatRoom(with stableId: String) {

        FirebaseUserListener.shared.downloadUser(with: [stableId]) { (users) in
            
            if users.count > 0 {
                
                let chatId = startChat(user1: User.currentUser!, user2: users.first!)
                
                let chatView = ChatViewController(chatId: chatId, recipientId: users.first!.id, recipientName: users.first!.name)

                DispatchQueue.main.async {
                    chatView.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(chatView, animated: true)
                }
            }
        }
    }

    
    private func showStableProfile(with stableId: String) {
        
        FirebaseUserListener.shared.downloadUser(with: [stableId]) { (users) in
            
            if users.count > 0 {
                
                let profileVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileView") as! UserProfileTableViewController
                
                profileVc.user = users.first!
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(profileVc, animated: true)
                }
            }
        }
    }
    
    private func showHorseProfile(with horseId: String) {
        
        let profileVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HorseProfileView") as! HorseProfileTableViewController
        self.navigationController?.pushViewController(profileVc, animated: true)

//        FirebaseUserListener.shared.downloadUser(with: [horseId]) { (horses) in
//
//            if users.count > 0 {
//
//        let profileVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HorseProfileView") as! HorseProfileTableViewController
//
//                profileVc.horse = horses.first!
//
//                DispatchQueue.main.async {
//        self.navigationController?.pushViewController(profileVc, animated: true)
//                }
//            }
//        }
    }


}
