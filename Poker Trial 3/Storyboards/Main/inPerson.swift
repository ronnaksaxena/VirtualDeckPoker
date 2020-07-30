//
//  inPerson.swift
//  Poker Trial 3
//
//  Created by Ronnak Saxena on 7/24/20.
//  Copyright © 2020 Ronnak Saxena & Sam Meyerowitz. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

class inPerson: UIViewController {
    
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.layer.cornerRadius = 10.0
        joinButton.tintColor = UIColor.white
        joinButton.layer.borderWidth = 2.0
        joinButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
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
}
