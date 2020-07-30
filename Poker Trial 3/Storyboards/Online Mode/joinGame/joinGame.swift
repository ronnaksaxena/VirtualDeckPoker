//
//  joinGame.swift
//  Poker Trial 3
//
//  Created by Ronnak Saxena on 6/13/20.
//  Copyright © 2020 Ronnak Saxena & Sam Meyerowitz. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase


class joinGame: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var codeText: UITextField!
    
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.layer.cornerRadius = 10.0
        joinButton.tintColor = UIColor.white
        joinButton.layer.borderWidth = 2.0
        joinButton.layer.borderColor = CGColor.init(srgbRed: 119/255, green: 136/255, blue: 153/255, alpha: 1)
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
                        guard let p = roomData?["players"] as? [[String:String]] else {
                            return
                        }
                        players = p
                        guard let sB = roomData?["small blind"] as? Int else {
                            return
                        }
                        guard let bB = roomData?["big blind"] as? Int else {
                            return
                        }
                        guard let stack = roomData?["default stack"] as? Int else {
                            return
                        }
                        guard let time = roomData?["time"] as? Int else {
                            return
                        }
                        
                        //adds player to room
                        rm = Room(smallBlind: sB, bigBlind: bB, defaultStack: stack, time: time, roomPlayers: players)
                        //checks to see if room is full
                        if rm.roomPlayers.count < 10 {
                            rm.addPlayer(name: name, seatNum: "0")
                            rm.roomCode = key
                            userPlayer = Player(name: name, isHost: false, stack: rm.defaultStack, isSitting: false, seatNum: 0)
                            ref.child(key).child("players").setValue(players)
                            
                            //segues to storyboard reference for gameTable
                            let storyboard = UIStoryboard(name: "joinGame", bundle: nil)
                            let myVC = storyboard.instantiateViewController(withIdentifier: "gameTable")
                            self.present(myVC, animated: true, completion: nil)
                        }
                        else {
                            self.errorLabel.text = "Can't join, room is full"
                        }
                    }
                }
            }
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


