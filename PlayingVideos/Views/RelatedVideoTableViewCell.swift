//
//  RelatedVideoTableViewCell.swift
//  PlayingVideos
//
//  Created by colorsLion2 on 29/01/19.
//  Copyright © 2019 colorsLion2. All rights reserved.
//

import UIKit

class RelatedVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLAbel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var videoContentView: UIView!
    @IBOutlet weak var relatedVideoImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.videoContentView.layer.shadowColor = UIColor.lightGray.cgColor
        self.videoContentView.layer.shadowOpacity = 1
        self.videoContentView.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.videoContentView.layer.shadowRadius = 2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
