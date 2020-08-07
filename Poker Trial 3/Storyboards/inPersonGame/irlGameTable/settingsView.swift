//
//  settingsView.swift
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
import Firebase

//var to keep track of selected player
var selectedPlayer:String = ""

class settingsView: UIViewController {
    
    /*override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !selectedPlayer.isEmpty {
            return true
        }
        return false
    }*/
    // new references
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var hostButton: UIButton!
    
    @IBOutlet weak var name1: UIButton!
    
    @IBOutlet weak var name2: UIButton!
    
    @IBOutlet weak var name3: UIButton!
    
    @IBOutlet weak var name4: UIButton!
    
    @IBOutlet weak var name5: UIButton!
    
    @IBOutlet weak var name6: UIButton!
    
    @IBOutlet weak var name7: UIButton!
    
    @IBOutlet weak var name8: UIButton!
    
    @IBOutlet weak var name9: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //adds borders to button
        // lime green (50,205,50)
        // dark red (139,0,0)
        removeButton.backgroundColor = UIColor.init(red: 139/255, green: 0/255, blue: 0/255, alpha: 1)
        removeButton.layer.cornerRadius = 10.0
        removeButton.tintColor = UIColor.white
        removeButton.layer.borderWidth = 2.0
        removeButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        hostButton.backgroundColor = UIColor.init(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
        hostButton.layer.cornerRadius = 10.0
        hostButton.tintColor = UIColor.white
        hostButton.layer.borderWidth = 2.0
        hostButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        //assign each label proper name
        let numOfPlayers:Int = inPersonPlayers.count
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            nameButtons[i].isHidden = true
        }
        var buttonCount = 0
        for i in stride(from: 0, to: numOfPlayers, by: 1) {
            if inPersonPlayers[i]["isHost"] == "false" {
                nameButtons[buttonCount].isHidden = false
                nameButtons[buttonCount].setTitle(inPersonPlayers[i]["name"], for: UIControl.State.normal)
                buttonCount = buttonCount + 1
            }
        }

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
       
    @IBAction func tapName1(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name1.isSelected = true
    }
    
    @IBAction func tapName2(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name2.isSelected = true
    }
    
    @IBAction func tapName3(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name3.isSelected = true
    }
    
    @IBAction func tapName4(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name4.isSelected = true
    }
    
    @IBAction func tapName5(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name5.isSelected = true
    }
    
    @IBAction func tapName6(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name6.isSelected = true
    }
    
    @IBAction func tapName7(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name7.isSelected = true
    }
    
    @IBAction func tapName8(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name8.isSelected = true
    }
    
    @IBAction func tapName9(_ sender: Any) {
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for i in stride(from: 0, to: nameButtons.count, by: 1) {
            if nameButtons[i].isSelected == true {
                nameButtons[i].isSelected = false
            }
        }
        name9.isSelected = true
    }
    
    
    @IBAction func tapRemoveButton(_ sender: Any) {
        // initializes selectedPlayer
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for button in nameButtons {
            if button.isSelected == true {
                if let buttonTitle = button.title(for: .normal) {
                    selectedPlayer = buttonTitle
                    print(selectedPlayer)
                }
            }
        }
        if !selectedPlayer.isEmpty {
            //segues to confirmation viewcontroller
            let storyboard = UIStoryboard(name: "settingsView", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "removeWarning")
            self.present(myVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func tapHostButton(_ sender: Any) {
        //initializes selectedPlayer
        let nameButtons:[UIButton] = [name1, name2, name3, name4, name5, name6, name7, name8, name9]
        for button in nameButtons {
            if button.isSelected == true {
                if let buttonTitle = button.title(for: .normal) {
                    selectedPlayer = buttonTitle
                }
            }
        }
        if !selectedPlayer.isEmpty {
            //segues to confirmation viewcontroller
            let storyboard = UIStoryboard(name: "settingsView", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "hostWarning")
            self.present(myVC, animated: true, completion: nil)
        }
    }
    
    
    
    
    
}
