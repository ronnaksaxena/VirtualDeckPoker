//
//  irlCreateGame.swift
//  Poker Trial 3
//
//  Created by Ronnak Saxena on 7/25/20.
//  Copyright © 2020 Ronnak Saxena & Sam Meyerowitz. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit
import FirebaseDatabase

//struct to keep track of player elements
struct irlPlayer {
    var name:String
    var isHost:String
    var card1:Card?
    var card2:Card?
    var folds:String
    init (name:String, isHost:String) {
        self.name = name
        self.isHost = isHost
        self.folds = "0"
    }
}

//struct to keep track of room elements
struct irlRoom {
    var roomCode:String = randomString(length: 6)
    var roomPlayers: [[String:String]] = []
    var gameStarted:String = "false"
    init (players:[[String:String]]) {
        self.roomPlayers = players
    }
    mutating func addPlayer(name:String) -> Void{
        let newPlayer:[String:String] = ["name":name, "isHost":"false", "card1":"00", "card2":"00", "folds":"0"]
        self.roomPlayers.append(newPlayer)
        inPersonPlayers = self.roomPlayers
    }
}

var inPersonPlayer = irlPlayer(name: "", isHost:"true")
var inPersonPlayers:[[String:String]] = []
var inPersonRm = irlRoom(players:inPersonPlayers)

class irlCreateGame: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var createGameButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createButton.layer.cornerRadius = 10.0
        createButton.tintColor = UIColor.white
        createButton.layer.borderWidth = 2.0
        createButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
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
    
    
    @IBAction func tapCreateGame(_ sender: Any) {
        //Gets name from textbox
        var nameText = ""
        if let nm = name.text{
            nameText = nm
        }
        
        //checks for valid inputs
        var errorMsg = ""
        if nameText.count > 10 || nameText.isEmpty {
            errorMsg = "Enter name between 1 and 10 characters"
        }
        
        if errorMsg.isEmpty {
            //updates global variables
            inPersonPlayer = irlPlayer(name: nameText, isHost:"true")
            inPersonPlayers = [["name":inPersonPlayer.name, "isHost":"true", "card1":"00", "card2":"00", "folds":"0"]]
            inPersonRm = irlRoom(players: inPersonPlayers)
            
            //updates new key in server
            let ref = Database.database().reference()
            ref.child(inPersonRm.roomCode).setValue(["roomPlayers": inPersonPlayers, "gameStarted":"false"])
                
            //segues to storyboard reference
            let storyboard = UIStoryboard(name: "irlCreateGame", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "irlGameTable")
            self.present(myVC, animated: true, completion: nil)
        }
        else {
            errorLabel.text = errorMsg
        }
            
            
            
            
            
            
    }
        
        
}
    

