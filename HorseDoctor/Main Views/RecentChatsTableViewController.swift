//
//  RecentChatsTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 20/09/2020.
//

import UIKit

class RecentChatsTableViewController: UITableViewController {

    //MARK: - Vars
    var allRecents:[RecentChat] = []
    var filteredRecents:[RecentChat] = []
    
    let searchController = UISearchController(searchResultsController: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()

//        createDummyUsers()
        tableView.tableFooterView = UIView()

        downloadRecentChats()
        setupSearchController()
    }


    //MARK: - DownloadRecents
    private func downloadRecentChats() {
        FirebaseRecentListener.shared.downloadRecentChatsFromFireStore { (allChats) in

            self.allRecents = allChats

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    
    // MARK: - Table view data source
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return searchController.isActive ? filteredRecents.count : allRecents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatTableViewCell

        let recentChat = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]

        cell.configureCell(recent: recentChat)

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]

        FirebaseRecentListener.shared.clearUnreadCounter(of: recent)
        goToChat(with: recent)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
            FirebaseRecentListener.shared.deleteRecent(recent)

            searchController.isActive ? self.filteredRecents.remove(at: indexPath.row) : self.allRecents.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }

    
    //MARK: - Navigation
    private func goToChat(with recent: RecentChat) {

        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)

        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)

        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }

    //MARK: - SearchController
    private func setupSearchController() {

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search User"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }

    private func filteredContentForSearchText(searchText: String) {

        filteredRecents = allRecents.filter({ (recent) -> Bool in

            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })

        tableView.reloadData()
    }
}


extension RecentChatsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}

