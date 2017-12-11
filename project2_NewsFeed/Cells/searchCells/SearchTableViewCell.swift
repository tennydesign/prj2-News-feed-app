//
//  SearchTableViewCell.swift
//  project2_NewsFeed
//
//  Created by Tennyson Pinheiro on 10/17/17.
//  Copyright © 2017 Tenny. All rights reserved.
//
// category: business, entertainment, gaming, general, health-and-medical, music, politics, science-and-nature, sport, technology.
// language: ar, en, cn, de, es, fr, he, it, nl, no, pt, ru, sv, ud.
//
import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var keywordView: UIView!
    @IBOutlet weak var keyword: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        keywordView.layer.cornerRadius = 12
        keywordView.layer.borderWidth = 0.3
        keywordView.layer.borderColor = UIColor.white.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
