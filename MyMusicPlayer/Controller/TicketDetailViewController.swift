//
//  TicketDetailViewController.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2020/06/28.
//  Copyright © 2020 葛西　翔太. All rights reserved.
//

import UIKit

class TicketDetailViewController: UIViewController {

    @IBOutlet weak var liveImageView: UIImageView!
    
    @IBOutlet weak var liveNameLabel: UILabel!
    
    @IBOutlet weak var livePlaceLabel: UILabel!
    
    @IBOutlet weak var liveDateLabel: UILabel!
    
    var image = ""
    var name = ""
    var date = ""
    var place = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        liveImageView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "noImage"), options: .continueInBackground, context: nil, progress: nil, completed: nil)
        liveNameLabel.text = name
        livePlaceLabel.text = place
        liveDateLabel.text = date
        
    }
    

    
}
