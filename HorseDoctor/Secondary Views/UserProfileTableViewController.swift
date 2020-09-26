//
//  UserProfileTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 22/09/2020.
//

import UIKit

class UserProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var isOnlineLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var telephoneLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    //MARK: - Vars
    var user: User?

    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        setupUI()
    }

    //MARK: - Tableview Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            let chatId = startChat(user1: User.currentUser!, user2: user!)
            
            let chatView = ChatViewController(chatId: chatId, recipientId: user!.id, recipientName: user!.name)

            chatView.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatView, animated: true)
        }
    }
    
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
        if user != nil {
            self.title = user!.name
            nameLabel.text = user!.name
            isOnlineLabel.text = user!.isOnline ? "Online" : "Offline"
            isOnlineLabel.textColor = user!.isOnline ? .systemGreen : .systemRed

            emailLabel.text = user!.email
            telephoneLabel.text = user!.telephone
            mobileLabel.text = user!.mobilePhone
            addressLabel.text = user!.address
            
            
            if user!.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }

}
