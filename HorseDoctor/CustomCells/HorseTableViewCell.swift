//
//  HorseTableViewCell.swift
//  HorseDoctor
//
//  Created by David Kababyan on 02/10/2020.
//

import UIKit

class HorseTableViewCell: UITableViewCell {

    //MARK: - IBActions
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chipIDLabel: UILabel!
    
    //MARK: - View LiceCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(with horse: Horse) {
        nameLabel.text = horse.name
        chipIDLabel.text = horse.chipId
        
        setAvatar(avatarLink: horse.avatarLink)
    }

    private func setAvatar(avatarLink: String) {
        
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }

}
