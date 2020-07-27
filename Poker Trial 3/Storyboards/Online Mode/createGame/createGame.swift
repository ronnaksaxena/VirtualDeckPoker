//
//  createGame.swift
//  Poker Trial 3
//
//  Created by Ronnak Saxena on 6/13/20.
//  Copyright © 2020 Ronnak Saxena & Sam Meyerowitz. All rights reserved.
//
 import UIKit
 import SpriteKit
 import GameplayKit
 import FirebaseDatabase

struct Player{
    var isHost = false
    var stack = 0
    var name = ""
    var isSitting = false
    var seatNum = 0
    init(name:String, isHost:Bool, stack:Int, isSitting:Bool, seatNum:Int){
        self.name = name
        self.isHost = isHost
        self.stack = stack
        self.isSitting = isSitting
        self.seatNum = seatNum
    }
    mutating func chooseSeat(seat:Int){
        self.seatNum = seat
        self.isSitting = true
    }
    
}

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

struct Room {
    var smallBlind = 10
    var bigBlind = 20
    var defaultStack = 1000
    var time = 30
    var roomPlayers: [[String:String]] = []
    var roomCode = randomString(length: 6)
    init(smallBlind:Int, bigBlind:Int, defaultStack:Int, time:Int, roomPlayers:[[String:String]]){
        self.smallBlind = smallBlind
        self.bigBlind = bigBlind
        self.defaultStack = defaultStack
        self.time = time
        self.roomPlayers = roomPlayers
    }
    mutating func changeSettings(smallBlind nSmallBlind:Int, bigBlind nBigBlind:Int, defaultStack nDefaultStack:Int, time nTime:Int) -> Void {
        smallBlind = nSmallBlind
        bigBlind = nBigBlind
        defaultStack = nDefaultStack
        time = nTime
    }
    mutating func addPlayer(name:String, seatNum:String) -> Void{
        let newPlayer:[String:String] = ["name":name, "isHost":"false", "stack":String(defaultStack), "isSitting":"false", "seatNum":seatNum]
        roomPlayers.append(newPlayer)
        players = roomPlayers
    }
    var description: String { return "Small Blind: \(smallBlind), Big Blind: \(bigBlind), Default Stack: \(defaultStack), Time: \(time), Code: \(roomCode), Players: \(roomPlayers)" }
}

//global variables to be updated every move
var players: [[String:String]] = []
var userPlayer = Player(name: "", isHost: true, stack: 1000, isSitting: false, seatNum: 0)
var rm = Room(smallBlind: 10, bigBlind: 20, defaultStack: 1000, time: 30, roomPlayers: players)


 class createGame: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var sbText: UITextField!
    
    @IBOutlet weak var bbText: UITextField!
    
    @IBOutlet weak var timeText: UITextField!
    
    @IBOutlet weak var stackText: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
         super.viewDidLoad()
     }
    
    //creates game and uploades to server when button is pressed
    @IBAction func tapCreateRoom(_ sender: Any) {
        
        
        //change text box inputs to desired types
        var sb = 0
        var bb = 0
        var stackVal = 0
        var timeVal = 0
        var name = ""
        var errorMsg = ""
        if let string = sbText.text, let smallB = Int(string){
            sb = smallB
        }
        if let string = bbText.text, let bigB = Int(string){
            bb = bigB
        }
        if let string = stackText.text, let stackT = Int(string){
            stackVal = stackT
        }
        if let string = timeText.text, let timeT = Int(string){
            timeVal = timeT
        }
        if let nm = nameText.text{
            name = nm
        }
        
        
        //check that data are acceptable values
        if (name == "") || (name.count > 10){
            errorMsg = errorMsg + "Enter name between 1 and 10 characters\n"
        }
        if (sb >= bb) || (sb <= 0){
            errorMsg = errorMsg + "Enter Valid Small Blind\n"
        }
        if (bb <= sb) || (bb <= 0){
            errorMsg = errorMsg + "Enter Valid Big Blind\n"
        }
        if (timeVal == 0){
            errorMsg = errorMsg + "Enter Valid Decision Time\n"
        }
        if (stackVal == 0){
            errorMsg = errorMsg + "Enter Valid Default Stack Size\n"
        }
        if (errorMsg != ""){
            errorLabel.text = errorMsg
        }
        else {

        //updates global variables and uploades room to firebase
        userPlayer = Player(name: name, isHost: true, stack: stackVal, isSitting: true, seatNum:1)
        let host:[String:String] = ["name": name, "isHost":"true", "stack":String(stackVal), "isSitting":"false", "seatNum":"1"]
        players = [host]
        rm = Room(smallBlind: sb, bigBlind: bb, defaultStack: stackVal, time: timeVal, roomPlayers: players)
        let ref = Database.database().reference()
        ref.child(rm.roomCode).setValue(["small blind": sb, "big blind": bb, "default stack": stackVal, "time": timeVal, "players": players])
            
        //segues to storyboard reference
        let storyboard = UIStoryboard(name: "createGame", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "gameTable")
        self.present(myVC, animated: true, completion: nil)
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
}


