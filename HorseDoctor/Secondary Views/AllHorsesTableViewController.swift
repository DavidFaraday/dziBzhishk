//
//  AllHorsesTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 03/10/2020.
//

import UIKit

protocol AllHorsesTableViewControllerDelegate {
    func didSelect(horse: Horse)
}

class AllHorsesTableViewController: UITableViewController {

    //MARK: - Vars
    var allHorses: [Horse] = []
    var filteredHorses: [Horse] = []

    let searchController = UISearchController(searchResultsController: nil)
    
    var selectedHorseId: String?
    var delegate: AllHorsesTableViewControllerDelegate?
    var userId: String?
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        self.title = "My Horses"
                
        if userId == nil {
            userId = User.currentId
        }
        
        setupSearchController()
        downloadHorses()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return searchController.isActive ? filteredHorses.count : allHorses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HorseTableViewCell

        let horse = searchController.isActive ? filteredHorses[indexPath.row] : allHorses[indexPath.row]
        
        if selectedHorseId != nil && horse.chipId == selectedHorseId {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.configure(with: horse)

        return cell
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let horse = searchController.isActive ? filteredHorses[indexPath.row] : allHorses[indexPath.row]
        
        if userId == User.currentId {
            delegate?.didSelect(horse: horse)
            navigationController?.popViewController(animated: true)
        } else {
            showHorseProfile(with: horse.id)
        }
    }

    
    //MARK: - Actions
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }


    
    //MARK: - Configuration
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    //MARK: - Download
    private func downloadHorses() {

        FirebaseHorseListener.shared.downloadHorses(for: userId!) { (allHorses) in
            
            self.allHorses = allHorses

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    //MARK: - SearchController
    private func setupSearchController() {

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search horse name"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }

    private func filteredContentForSearchText(searchText: String) {

        filteredHorses = allHorses.filter({ (horse) -> Bool in

            return horse.name.lowercased().contains(searchText.lowercased())
        })

        tableView.reloadData()
    }

    private func showHorseProfile(with horseId: String) {
        
        let profileVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HorseProfileView") as! HorseProfileTableViewController
        
        profileVc.horseId = horseId
        self.navigationController?.pushViewController(profileVc, animated: true)
    }

}

extension AllHorsesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}



