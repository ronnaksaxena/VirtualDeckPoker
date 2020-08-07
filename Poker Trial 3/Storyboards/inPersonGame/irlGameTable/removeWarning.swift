//
//  removeWarning.swift
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


class removeWarning: UIViewController {
    
    @IBOutlet weak var whiteBlock: UIImageView!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    
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
        warningLabel.text = "Are you sure you want to remove \(selectedPlayer)?"


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
    
    @IBAction func tapNo(_ sender: Any) {
        selectedPlayer = ""
        //segues back to settings
        let storyboard = UIStoryboard(name: "removeWarning", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "settingsView")
        self.present(myVC, animated: true, completion: nil)

    }
    
    @IBAction func tapYes(_ sender: Any) {
        //deletes player from InPersonPlayers
        for i in stride(from: 0, to: inPersonPlayers.count, by: 1) {

            if inPersonPlayers[i]["name"] == selectedPlayer {
                inPersonPlayers.remove(at: i)
                break
            }
        }
        //updates server
        let ref = Database.database().reference()
        ref.child(inPersonRm.roomCode).child("roomPlayers").setValue(inPersonPlayers)
        //segues back to settings
        selectedPlayer = ""
        let storyboard = UIStoryboard(name: "removeWarning", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "settingsView")
        self.present(myVC, animated: true, completion: nil)
    }
}
