//
//  EmergencyTableViewController.swift
//  HorseDoctor
//
//  Created by David Kababyan on 23/09/2020.
//

import UIKit

class EmergencyTableViewController: UITableViewController {

    
    //MARK: - Vars
    var allEmergencies: [EmergencyAlert] = []
    

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        listenForEmergencies()
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
    }


    
    //MARK: - IBActions
    @IBAction func addEmergencyBarButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: SegueType.emergencyToAddEmergencySeg.rawValue, sender: self)
    }
    
    //MARK: - Download
    private func listenForEmergencies() {
        FirebaseEmergencyAlertListener.shared.listenForEmergencyAlerts { (allEmergencies) in
            
            self.allEmergencies = allEmergencies
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

    }


}
