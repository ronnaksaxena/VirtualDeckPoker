//
//  gameTable.swift
//  Poker Trial 3
//
//  Created by Ronnak Saxena on 6/16/20.
//  Copyright © 2020 Ronnak Saxena & Sam Meyerowitz. All rights reserved.
//
import UIKit
import SpriteKit
import GameplayKit
import Firebase

var gameStarted:Bool = false


func binarySearch<T:Comparable>(_ inputArr:Array<T>, _ searchItem: T) -> Int {
    var lowerIndex = 0
    var upperIndex = inputArr.count - 1

    while (true) {
        let currentIndex = (lowerIndex + upperIndex)/2
        if(inputArr[currentIndex] == searchItem) {
            return currentIndex
        }
        else {
            if (inputArr[currentIndex] > searchItem) {
                upperIndex = currentIndex - 1
            } else {
                lowerIndex = currentIndex + 1
            }
        }
    }
}

class gameTable: UIViewController {

    
    @IBOutlet weak var seat1: UIButton!
    
    @IBOutlet weak var seat2: UIButton!
    
    @IBOutlet weak var seat3: UIButton!
    
    @IBOutlet weak var seat4: UIButton!
    
    @IBOutlet weak var seat5: UIButton!
    
    @IBOutlet weak var seat6: UIButton!
    
    @IBOutlet weak var seat7: UIButton!
    
    @IBOutlet weak var seat8: UIButton!
    
    @IBOutlet weak var seat9: UIButton!
    
    @IBOutlet weak var seat10: UIButton!
    
    @IBOutlet weak var name1: UILabel!
    
    @IBOutlet weak var name2: UILabel!
    
    @IBOutlet weak var name3: UILabel!
    
    @IBOutlet weak var name4: UILabel!
    
    @IBOutlet weak var name5: UILabel!
    
    @IBOutlet weak var name6: UILabel!
    
    @IBOutlet weak var name7: UILabel!
    
    @IBOutlet weak var name8: UILabel!
    
    @IBOutlet weak var name9: UILabel!
    
    @IBOutlet weak var name10: UILabel!
    
    @IBOutlet weak var seat1Card1: UIImageView!
    
    @IBOutlet weak var seat1Card2: UIImageView!
    
    @IBOutlet weak var seat2Card1: UIImageView!
    
    @IBOutlet weak var seat2Card2: UIImageView!
    
    @IBOutlet weak var seat3Card1: UIImageView!
    
    @IBOutlet weak var seat3Card2: UIImageView!
    
    @IBOutlet weak var seat4Card1: UIImageView!
    
    @IBOutlet weak var seat4Card2: UIImageView!
    
    @IBOutlet weak var seat5Card1: UIImageView!
    
    @IBOutlet weak var seat5Card2: UIImageView!
    
    @IBOutlet weak var seat6Card2: UIImageView!
    
    @IBOutlet weak var seat6Card1: UIImageView!
    
    @IBOutlet weak var seat7Card1: UIImageView!
    
    @IBOutlet weak var seat7Card2: UIImageView!
    
    @IBOutlet weak var seat8Card1: UIImageView!
    
    @IBOutlet weak var seat8Card2: UIImageView!
    
    @IBOutlet weak var seat9Card1: UIImageView!
    
    @IBOutlet weak var seat9Card2: UIImageView!
    
    @IBOutlet weak var seat10Card1: UIImageView!
    
    @IBOutlet weak var seat10Card2: UIImageView!
    
    @IBOutlet weak var flop1: UIImageView!
    
    @IBOutlet weak var flop2: UIImageView!
    
    @IBOutlet weak var flop3: UIImageView!
    
    @IBOutlet weak var turn: UIImageView!
    
    @IBOutlet weak var river: UIImageView!
    
    @IBOutlet weak var pot: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var betButton: UIButton!
    
    @IBOutlet weak var foldButton: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if userPlayer.seatNum == 1 {
            name1.text = userPlayer.name
            seat1.isHidden = true
            seat2.isHidden = true
            seat3.isHidden = true
            seat4.isHidden = true
            seat5.isHidden = true
            seat6.isHidden = true
            seat7.isHidden = true
            seat8.isHidden = true
            seat9.isHidden = true
            seat10.isHidden = true
            seat1Card1.isHidden = true
            seat1Card2.isHidden = true
            seat2Card1.isHidden = true
            seat2Card2.isHidden = true
            seat3Card1.isHidden = true
            seat3Card2.isHidden = true
            seat4Card1.isHidden = true
            seat4Card2.isHidden = true
            seat5Card1.isHidden = true
            seat5Card2.isHidden = true
            seat6Card1.isHidden = true
            seat6Card2.isHidden = true
            seat7Card1.isHidden = true
            seat7Card2.isHidden = true
            seat8Card1.isHidden = true
            seat8Card2.isHidden = true
            seat9Card1.isHidden = true
            seat9Card2.isHidden = true
            seat10Card1.isHidden = true
            seat10Card2.isHidden = true
            flop1.isHidden = true
            flop2.isHidden = true
            flop3.isHidden = true
            turn.isHidden = true
            river.isHidden = true
            checkButton.isHidden = true
            betButton.isHidden = true
            foldButton.isHidden = true
            continueButton.isHidden = true
            pot.text = "Room code: \(rm.roomCode)"
        }
        if userPlayer.seatNum == 0 {
            continueButton.isHidden = true
            startButton.isHidden = true
            checkButton.isHidden = true
            betButton.isHidden = true
            foldButton.isHidden = true
            let cards: [(card1: UIImageView, card2: UIImageView)] = [(seat1Card1, seat1Card2), (seat2Card1, seat2Card2), (seat3Card1, seat3Card2), (seat4Card1, seat4Card2), (seat5Card1, seat5Card2), (seat6Card1, seat6Card2), (seat7Card1, seat7Card2), (seat8Card1, seat8Card2), (seat9Card1, seat9Card2), (seat10Card1, seat10Card2)]
            let communityCards = [flop1, flop2, flop3, turn, river]
            let seats = [seat1, seat2, seat3, seat4, seat5, seat6, seat7, seat8, seat9, seat10]
            var emptySeats = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let names = [name1, name2, name3, name4, name5, name6, name7, name8, name9, name10]
            
            for seat in stride(from: 0, through: players.count - 1, by: 1){
                if players[seat]["seatNum"] != "0" {
                    guard let playerSeat = players[seat]["seatNum"] else {
                        return
                    }
                    guard let num = Int(playerSeat) else {
                        return
                    }
                    names[num - 1]?.text = players[seat]["name"]
                    seats[num - 1]?.isHidden = true
                    emptySeats.remove(at: binarySearch(emptySeats, num))
                }
            }
            for seat in emptySeats {
                seats[seat - 1]?.setTitle("Sit", for: UIControl.State.normal)
                seats[seat - 1]?.backgroundColor = UIColor.init(red: 48/265, green: 173/255, blue: 99/255, alpha: 1)
                seats[seat - 1]?.layer.cornerRadius = 10.0
                seats[seat - 1]?.tintColor = UIColor.white
            }
            if gameStarted == false {
                for seat in cards {
                    let firstCard = seat.0
                    let secondCard = seat.1
                    firstCard.isHidden = true
                    secondCard.isHidden = true
                }
                for card in communityCards {
                    card?.isHidden = true
                }
                pot.text = "Room code: \(rm.roomCode)"
            }
            else if gameStarted == true {
                for seat in cards {
                    let firstCard = seat.0
                    let secondCard = seat.1
                    firstCard.isHidden = true
                    secondCard.isHidden = true
                }
                for player in players{
                    guard let num = Int(player["seatNum"] ?? "0") else {
                        print("Error here")
                        return
                    }
                    if num > 0 {
                        let myTuple: (card1: UIImageView, card2: UIImageView)? = cards[num - 1]
                        let firstCard = myTuple?.0
                        let secondCard = myTuple?.1
                        firstCard?.isHidden = false
                        secondCard?.isHidden = false
                    }
                }
                for card in communityCards {
                    card?.isHidden = false
                }
            }
            
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.landscape
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func clickSeat1(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "1"
                players[i]["isSitting"] = "true"
                name2.text = userPlayer.name
                seat2.isHidden = true
            }
            let ref = Database.database().reference()
            ref.child(rm.roomCode).child("players").setValue(players)
        }
        
    }
    
    @IBAction func clickSeat2(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "2"
                players[i]["isSitting"] = "true"
                name2.text = userPlayer.name
                seat2.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    @IBAction func clickSeat3(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "3"
                players[i]["isSitting"] = "true"
                name3.text = userPlayer.name
                seat3.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    @IBAction func clickSeat4(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "4"
                players[i]["isSitting"] = "true"
                name4.text = userPlayer.name
                seat4.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    @IBAction func clickSeat5(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "5"
                players[i]["isSitting"] = "true"
                name5.text = userPlayer.name
                seat5.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    @IBAction func clickSeat6(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "6"
                players[i]["isSitting"] = "true"
                name6.text = userPlayer.name
                seat6.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    @IBAction func clickSeat7(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "7"
                players[i]["isSitting"] = "true"
                name7.text = userPlayer.name
                seat7.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    @IBAction func clickSeat8(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "8"
                players[i]["isSitting"] = "true"
                name8.text = userPlayer.name
                seat8.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    @IBAction func clickSeat9(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "9"
                players[i]["isSitting"] = "true"
                name9.text = userPlayer.name
                seat9.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    @IBAction func clickSeat10(_ sender: Any) {
        for i in stride(from: 0, to: players.count, by: 1){
            if players[i]["name"] == userPlayer.name && players[i]["seatNum"] == "0"{
                players[i]["seatNum"] = "10"
                players[i]["isSitting"] = "true"
                name10.text = userPlayer.name
                seat10.isHidden = true
            }
        }
        let ref = Database.database().reference()
        ref.child(rm.roomCode).child("players").setValue(players)
    }
    
    
    
    
}


