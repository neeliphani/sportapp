//
//  TeamDetailsViewController.swift
//  SportsApp
//
//  Created by Alaa on 21/05/2023.
//

import UIKit

class TeamDetailsViewController: UIViewController {
    
    @IBOutlet weak var teamImage: UIImageView!
    
    @IBOutlet weak var teamSportName: UILabel!
    
    @IBOutlet weak var teamName: UILabel!
    
    var team: Team!
    var sport: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        teamName.text = team.teamName
        teamImage.setRemoteImage(from: team.teamLogo,
                                 placeholder: UIImage(named: "noImg"))
        teamSportName.text = sport.capitalized + " Team"
        
    }
    
}
