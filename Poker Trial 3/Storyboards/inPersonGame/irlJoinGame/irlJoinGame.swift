//
//  irlJoinGame.swift
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


class irlJoinGame: UIViewController {
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var codeText: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    @IBOutlet weak var joinButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.layer.cornerRadius = 10.0
        joinButton.tintColor = UIColor.white
        joinButton.layer.borderWidth = 2.0
        joinButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
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
    
    enum joinGameError:Error{
        case invalidName
    }
    
    func join(name:String, code:String) throws -> Void {
        var codeFlag:Bool = false
        if name.isEmpty || (name.count > 10) {
            throw joinGameError.invalidName
        }
        let ref = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                if code == key{
                    codeFlag = true
                    ref.child(key).observeSingleEvent(of: .value)
                    { (snapshot) in
                        let roomData = snapshot.value as? [String:Any]
                        guard let p = roomData?["roomPlayers"] as? [[String:String]] else {
                            return
                        }
                        guard let c = roomData?["comCards"] as? [String] else {
                            return
                        }
                        
                        //recieves global variables
                        inPersonPlayers = p
                        inPersonRm = irlRoom(players: inPersonPlayers)
                        inPersonRm.comCards = c
                        
                        var hasDuplicate:Bool = false
                        for player in inPersonPlayers {
                            if player["name"] == name {
                                hasDuplicate = true
                            }
                        }
                        if hasDuplicate {
                            self.errorLabel.text = "Name is taken\n"
                        }
                        else {
                            //checks to see if room is full
                            if (inPersonRm.roomPlayers.count < 10) {
                                inPersonRm.addPlayer(name: name)
                                inPersonRm.roomCode = key
                                inPersonPlayer = irlPlayer(name: name, isHost: "false")
                                ref.child(key).child("roomPlayers").setValue(inPersonPlayers)
                                
                                //segues to storyboard reference for gameTable
                                let storyboard = UIStoryboard(name: "irlJoinGame", bundle: nil)
                                let myVC = storyboard.instantiateViewController(withIdentifier: "irlGameTable")
                                self.present(myVC, animated: true, completion: nil)
                            }
                            else {
                                self.errorLabel.text = "Can't join, room is full"
                            }
                        }
                    }
                }
            }
            //checks to see if code is found
            if codeFlag == false {
                self.errorLabel.text = "Invalid code"
            }
            
        })
    }
    
    @IBAction func tapJoin(_ sender: Any) {
        //changes optional variables to desired values
        var errorMsg = ""
        var name = ""
        var code = ""
        //var flag:Bool = false
        if let nm = nameText.text{
            name = nm
        }
        if let cd = codeText.text{
            code = cd
        }
        do {
            try join(name: name, code: code)
        } catch joinGameError.invalidName{
            errorMsg += "Enter name between 1 and 10 characters\n"
        } catch {
            print("Unexpected error: \(error).")
        }
        errorLabel.text = errorMsg
    }
    
    
}
