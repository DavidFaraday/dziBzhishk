//
//  HorsesTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 02/10/2020.
//

import UIKit
import EmptyDataSet_Swift

class HorsesTableViewController: UITableViewController {

    //MARK: - Vars
    var allHorses: [Horse] = []
    var filteredHorses: [Horse] = []

    let searchController = UISearchController(searchResultsController: nil)

    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl

        //Shows empty data view when no news are stored
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
        
        setupSearchController()
        downloadHorses()
    }
    
    
    //MARK: - IBActions
    @IBAction func addHorseBarButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: SegueType.horseToAddHorseSeg.rawValue, sender: self)
    }
    
    //MARK: - Download
    private func downloadHorses() {
        FirebaseHorseListener.shared.downloadHorses(for: User.currentId) { (allHorses) in
            
            self.allHorses = allHorses
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }



    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return searchController.isActive ? filteredHorses.count : allHorses.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HorseTableViewCell

        let horse = searchController.isActive ? filteredHorses[indexPath.row] : allHorses[indexPath.row]

        cell.configure(with: horse)
        
        return cell
    }
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: SegueType.horseToAddHorseSeg.rawValue, sender: allHorses[indexPath.row])

    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            let horse = searchController.isActive ? filteredHorses[indexPath.row] : allHorses[indexPath.row]
            
            FirebaseHorseListener.shared.deleteHorse(horse)

            searchController.isActive ? self.filteredHorses.remove(at: indexPath.row) : self.allHorses.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == SegueType.horseToAddHorseSeg.rawValue {
            
            let addHorseVC = segue.destination as! AddHorseTableViewController
            
            addHorseVC.horseToEdit = sender as? Horse
            addHorseVC.delegate = self
        }
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if self.refreshControl!.isRefreshing {
            
            downloadHorses()
            self.refreshControl!.endRefreshing()
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
}

extension HorsesTableViewController: AddHorseTableViewControllerDelegate {
    
    func didFinishAddingHorse() {
        downloadHorses()
    }    
}


extension HorsesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}



//extension HorsesTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
//    
//    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        
//        return NSAttributedString(string: "No horses to display!")
//    }
//    
//    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
//        
//        
//        return UIImage(named: "horse")?.withTintColor(UIColor.systemGray)
//    }
//    
//    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        return NSAttributedString(string: "Click on plus button to create one.")
//    }
//    
//}
