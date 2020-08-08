//
//  hostWarning.swift
//  Poker Trial 3
//
//  Created by Ronnak Saxena on 7/31/20.
//  Copyright © 2020 Ronnak Saxena & Sam Meyerowitz. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit
import FirebaseDatabase

class hostWarning: UIViewController {
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var whiteBlock: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets borders around buttons
        // lime green (50,205,50)
        // dark red (139,0,0)
        noButton.backgroundColor = UIColor.init(red: 139/255, green: 0/255, blue: 0/255, alpha: 1)
        noButton.layer.cornerRadius = 10.0
        noButton.tintColor = UIColor.white
        noButton.layer.borderWidth = 2.0
        noButton.layer.borderColor = CGColor.init(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        yesButton.backgroundColor = UIColor.init(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
        yesButton.layer.cornerRadius = 10.0
        yesButton.tintColor = UIColor.white
        yesButton.layer.borderWidth = 2.0
        yesButton.layer.borderColor = CGColor.init(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        whiteBlock.layer.cornerRadius = 10.0
        warningLabel.text = "Are you sure you want to make \(selectedPlayer) host?"


    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func tapNoButton(_ sender: Any) {
        selectedPlayer = ""
        //segues back to settings view controller
        let storyboard = UIStoryboard(name: "hostWarning", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "settingsView")
        self.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func tapYesButton(_ sender: Any) {
        var playersCopy = inPersonPlayers
        // makes other player host and makes user not host
        for i in stride(from: 0, to: inPersonPlayers.count, by: 1) {
            if playersCopy[i]["isHost"] == "true" {
                playersCopy[i]["isHost"] = "false"
            }
            if playersCopy[i]["name"] == selectedPlayer {
                playersCopy[i]["isHost"] = "true"
            }
        }
        //updates global variables
        inPersonPlayer.isHost = "false"
        //updates server
        let ref = Database.database().reference()
        ref.child(inPersonRm.roomCode).child("roomPlayers").setValue(playersCopy)
        //segues back to settings
        let storyboard = UIStoryboard(name: "hostWarning", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "irlGameTable")
        self.present(myVC, animated: true, completion: nil)
    }
    
}
