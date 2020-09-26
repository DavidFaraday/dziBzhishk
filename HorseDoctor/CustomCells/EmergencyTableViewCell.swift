//
//  EmergencyTableViewCell.swift
//  HorseDoctor
//
//  Created by David Kababyan on 23/09/2020.
//

import UIKit

class EmergencyTableViewCell: UITableViewCell {

    //MARK: - IOutlets
    @IBOutlet weak var stableNameLabel: UILabel!
    @IBOutlet weak var emergencyTypeLabel: UILabel!
    @IBOutlet weak var emergencyDateLabel: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    //MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with emergency: EmergencyAlert) {

        stableNameLabel.text = emergency.stableName
        emergencyTypeLabel.text = emergency.type
        emergencyDateLabel.text = timeElapsed((emergency.isResponded ? emergency.respondedDate : emergency.date) ?? Date())
        
        statusImageView.image = emergency.isResponded ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        statusImageView.tintColor = emergency.isResponded ? .systemGreen : .systemRed
    }

}
