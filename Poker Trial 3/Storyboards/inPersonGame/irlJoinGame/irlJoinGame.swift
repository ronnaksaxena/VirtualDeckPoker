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
import MessageUI


class irlJoinGame: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var codeText: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    @IBOutlet weak var joinButton: UIButton!
    
    
    @IBOutlet weak var bugButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.layer.cornerRadius = 10.0
        joinButton.tintColor = UIColor.white
        joinButton.layer.borderWidth = 2.0
        joinButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        bugButton.backgroundColor = UIColor.init(red: 139/255, green: 0/255, blue: 0/255, alpha: 1)
        bugButton.layer.cornerRadius = 10.0
        bugButton.tintColor = UIColor.white
        bugButton.layer.borderWidth = 2.0
        bugButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        //assigns delegates
        nameText.delegate = self
        codeText.delegate = self
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
                                //updates variables
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
    //makes keyboard hidden when tapped outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //makes keyboard hidden when return is tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameText {
            textField.resignFirstResponder()
        }
        else if textField == codeText {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //sends email to fix bugs
    @IBAction func tapBugButton(_ sender: Any) {
        showMailComposer()
    }
    
    func showMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else{
            //tell user they can't sent email
            return
            
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["virtualdeckpoker@gmail.com"])
        composer.setSubject("Bug Report From User")
        composer.setMessageBody("", isHTML: false)
        
        present(composer, animated:true)
        
    }
    
    
}

 
extension UIViewController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            //show error
            controller.dismiss(animated: true)
        }
        
        switch result {
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        default:
            print("nothing")
        }
        
        controller.dismiss(animated: true)
    }
    
}
