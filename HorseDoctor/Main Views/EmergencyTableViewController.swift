//
//  EmergencyTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 23/09/2020.
//

import UIKit
import EmptyDataSet_Swift

class EmergencyTableViewController: UITableViewController {

    
    //MARK: - Vars
    var allEmergencies: [EmergencyAlert] = []
    

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        //Shows empty data view when no news are stored
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        
        listenForEmergencies(for: User.currentUser!.userType)
        
        if User.currentUser!.userType == UserType.Stable {
            configureRightBarButton()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return allEmergencies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EmergencyTableViewCell
        
        cell.configure(with: allEmergencies[indexPath.row])
        
        return cell
    }
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let segueId = User.currentUser!.userType == .Stable ? SegueType.emergencyToAddEmergencySeg.rawValue : SegueType.emergencyToEmergencyDetailSeg.rawValue
        
        performSegue(withIdentifier: segueId, sender: allEmergencies[indexPath.row])
    }


    
    //MARK: - Actions
    @objc func addEmergencyBarButtonPressed() {
        
        performSegue(withIdentifier: SegueType.emergencyToAddEmergencySeg.rawValue, sender: self)
    }
    
    //MARK: - Download
    private func listenForEmergencies(for userType: UserType) {
        
        FirebaseEmergencyAlertListener.shared.listenForEmergencyAlerts(for: userType) { (allEmergencies) in
            
            self.allEmergencies = allEmergencies
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueType.emergencyToEmergencyDetailSeg.rawValue {
            
            let detailVc = segue.destination as! EmergencyDetailTableViewController
            
            detailVc.emergency = sender as? EmergencyAlert
        }
        
        if segue.identifier == SegueType.emergencyToAddEmergencySeg.rawValue {
            
            let editVc = segue.destination as! AddEmergencyTableViewController
            
            editVc.emergencyToEdit = sender as? EmergencyAlert
        }

    }

    //MARK: - UISetup
    private func configureRightBarButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addEmergencyBarButtonPressed))
    }


}


extension EmergencyTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "No emergencies to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        
        return UIImage(named: "emergency")?.withTintColor(UIColor.systemGray)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "")
    }
    
}
