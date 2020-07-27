//
//  irlGameTable.swift
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

public enum Rank:Int {
    case Two = 2, Three, Four, Five, Six, Seven, Eight, Nine, Ten
    case Jack, Queen, King, Ace
}

public enum Suit:Int {
    case Diamond
    case Heart
    case Club
    case Spade
}

public struct Card {
    let suit: Suit
    let rank: Rank
}

public struct Deck {
 
    public var cardsInPile: [Card]
    private let randomNumberGenerator: GKARC4RandomSource
 
    public var totalNumberOfCards: Int {
        return cardsInPile.count
    }
    
    init() {
        var cards = [Card]()
        
        for rankValue in 2 ... 14 {
            for suitValue in 0 ..< 4 {
        
                let suit = Suit(rawValue: suitValue)!
                let rank = Rank(rawValue: rankValue)!
        
                cards += [Card(suit: suit, rank: rank)]
            }
        }
        self.cardsInPile = cards
        self.randomNumberGenerator = GKARC4RandomSource()
    }
    
    init(cards: [Card], seed: Data? = nil) {
        self.cardsInPile = cards
        let seed = seed ?? Date().description.data(using: .utf8)!
        randomNumberGenerator = GKARC4RandomSource(seed: seed)
    }
    
    public func contains(card: Card) -> Bool {
        return cardsInPile.contains(card)
    }
    
    @discardableResult public mutating func drawCard() -> Card? {
        if cardsInPile.count == 0 { return nil }
        let randomIndex = randomNumberGenerator.nextInt(upperBound: cardsInPile.count)
        return cardsInPile.remove(at: randomIndex)
    }
}

extension Card: Equatable {
    public static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
}

public struct Hand {
    private let cards: [Card]
 
    public var numberOfCards: Int {
        return cards.count
    }
 
    init(cards: [Card]) {
        self.cards = cards
    }
    public static func ==(lhs: Hand, rhs: Hand) -> Bool {
           let lhsCards = lhs.cards.sorted(by: >)
           let rhsCards = rhs.cards.sorted(by: >)
    
           for (lhsCard, rhsCard) in zip(lhs.cards, rhs.cards) {
               if lhsCard.rank != rhsCard.rank {
                   return false
               }
           }
    
           return true
       }
}

extension Card: Comparable {
    public static func <(lhs: Card, rhs: Card) -> Bool {
        return lhs.rank.rawValue < rhs.rank.rawValue
    }
}

extension Hand: Comparable {
    public static func <(lhs: Hand, rhs: Hand) -> Bool {
        let lhsCards = lhs.cards.sorted(by: >)
        let rhsCards = rhs.cards.sorted(by: >)
 
        for (lhsCard, rhsCard) in zip(lhsCards, rhsCards) {
            if lhsCard.rank == rhsCard.rank { continue }
            return lhsCard < rhsCard
        }
        return false
    }
}

public enum HandStrength: Int {
    case EmptyHand, HighCard, Pair, TwoPair, ThreeOfAKind, Straight, Flush, FullHouse, FourOfAKind, StraightFlush
}

func cardToString(card:Card) ->String {
    let rank = card.rank
    let suit = card.suit
    var cardString:String = ""
    if rank == Rank.Two {
        cardString = cardString + "2"
    }
    if rank == Rank.Three {
        cardString = cardString + "3"
    }
    if rank == Rank.Four {
        cardString = cardString + "4"
    }
    if rank == Rank.Five {
        cardString = cardString + "5"
    }
    if rank == Rank.Six {
        cardString = cardString + "6"
    }
    if rank == Rank.Seven {
        cardString = cardString + "7"
    }
    if rank == Rank.Eight {
        cardString = cardString + "8"
    }
    if rank == Rank.Nine {
        cardString = cardString + "9"
    }
    if rank == Rank.Ten {
        cardString = cardString + "10"
    }
    if rank == Rank.Jack {
        cardString = cardString + "J"
    }
    if rank == Rank.Queen {
        cardString = cardString + "Q"
    }
    if rank == Rank.King {
        cardString = cardString + "K"
    }
    if rank == Rank.Ace {
        cardString = cardString + "A"
    }
    if suit == Suit.Heart {
        cardString = cardString + "H"
    }
    if suit == Suit.Diamond {
        cardString = cardString + "D"
    }
    if suit == Suit.Spade {
        cardString = cardString + "S"
    }
    if suit == Suit.Club {
        cardString = cardString + "C"
    }
    return cardString
}



class irlGameTable: UIViewController {
    
    @IBOutlet weak var dealButton: UIButton!
    
    @IBOutlet weak var foldButton: UIButton!
    
    @IBOutlet weak var handButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var leaveButton: UIButton!
    
    @IBOutlet weak var flop1: UIImageView!
    
    @IBOutlet weak var flop2: UIImageView!
    
    @IBOutlet weak var flop3: UIImageView!
    
    @IBOutlet weak var turn: UIImageView!
    
    @IBOutlet weak var river: UIImageView!
    
    @IBOutlet weak var name1: UIButton!
    
    @IBOutlet weak var name2: UIButton!
    
    @IBOutlet weak var name3: UIButton!
    
    @IBOutlet weak var name4: UIButton!
    
    @IBOutlet weak var name5: UIButton!
    
    @IBOutlet weak var name6: UIButton!
    
    @IBOutlet weak var name7: UIButton!
    
    @IBOutlet weak var name8: UIButton!
    
    @IBOutlet weak var name9: UIButton!
    
    @IBOutlet weak var name10: UIButton!
    
    @IBOutlet weak var card1: UIImageView!
    
    @IBOutlet weak var card2: UIImageView!
    
    @IBOutlet weak var handLabel: UILabel!
    
    @IBOutlet weak var roomCode: UILabel!
    
    @IBOutlet weak var waitingLabel: UILabel!
    
    
    var rmDeck:Deck = Deck()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //(218,165,32) golden rod
        //(139,0,0) dark red
        //(65,105,225) royal blue
        //adds borders to buttons
        dealButton.backgroundColor = UIColor.init(red: 218/255, green: 165/255, blue: 32/255, alpha: 1)
        dealButton.layer.cornerRadius = 10.0
        dealButton.tintColor = UIColor.white
        dealButton.layer.borderWidth = 2.0
        dealButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        foldButton.backgroundColor = UIColor.init(red: 139/255, green: 0/255, blue: 0/255, alpha: 1)
        foldButton.layer.cornerRadius = 10.0
        foldButton.tintColor = UIColor.white
        foldButton.layer.borderWidth = 2.0
        foldButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        handButton.backgroundColor = UIColor.init(red: 65/255, green: 105/255, blue: 225/255, alpha: 1)
        handButton.layer.cornerRadius = 10.0
        handButton.tintColor = UIColor.white
        handButton.layer.borderWidth = 2.0
        handButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        settingsButton.backgroundColor = UIColor.init(red: 65/255, green: 105/255, blue: 225/255, alpha: 1)
        settingsButton.layer.cornerRadius = 10.0
        settingsButton.tintColor = UIColor.white
        settingsButton.layer.borderWidth = 2.0
        settingsButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        leaveButton.backgroundColor = UIColor.init(red: 139/255, green: 0/255, blue: 0/255, alpha: 1)
        leaveButton.layer.cornerRadius = 10.0
        leaveButton.tintColor = UIColor.white
        leaveButton.layer.borderWidth = 2.0
        leaveButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        //groups to use later
        let comCards = [flop1, flop2, flop3, turn, river]
        let names = [name1, name2, name3, name4, name5, name6, name7, name8, name9, name10]
        
        
        //screen for host
        if inPersonPlayer.isHost == "true" {
            leaveButton.isHidden = true
            dealButton.isHidden = true
            foldButton.isHidden = true
            name1.setTitle(inPersonPlayer.name, for: UIControl.State.normal)
            for card in comCards {
                card?.isHidden = true
            }
            for i in stride(from: 1, through: 9, by: 1) {
                names[i]?.isHidden = true
            }
            handLabel.isHidden = true
            roomCode.text = "Room Code:\n\(inPersonRm.roomCode)"
        }
        else {
            if inPersonRm.gameStarted == "false" {
                waitingLabel.isHidden = false
            }
            settingsButton.isHidden = true
            dealButton.isHidden = true
            handButton.isHidden = true
            foldButton.isHidden = true
            roomCode.text = "Room Code:\n\(inPersonRm.roomCode)"
            dealButton.isHidden = true
            handLabel.isHidden = true
            for i in stride(from: 0, through: 9, by: 1) {
                names[i]?.isHidden = true
            }
            for i in stride(from: 0, through: inPersonPlayers.count - 1, by: 1) {
                names[i]?.isHidden = false
                guard let name = inPersonPlayers[i]["name"] else {
                    print("Error here")
                    return
                }
                names[i]?.setTitle(name, for: UIControl.State.normal)
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
    
    @IBAction func tapNewHand(_ sender: Any) {
        //resets all visuals
        rmDeck = Deck()
        dealButton.isHidden = false
        foldButton.isHidden = false
        let comCards = [flop1, flop2, flop3, turn, river]
        for card in comCards {
            card?.isHidden = false
            card?.image = UIImage(named: "back")
        }
        
        //starts game
        if inPersonRm.gameStarted == "false" {
            inPersonRm.gameStarted = "true"
            let ref = Database.database().reference()
            ref.child(inPersonRm.roomCode).child("gameStarted").setValue("true")
        }
        
        //changes cards on screen to random drawn cards
        let c1:Card = rmDeck.drawCard() ?? Card(suit: Suit.Diamond, rank: Rank.Two)
        let c2:Card = rmDeck.drawCard() ?? Card(suit: Suit.Diamond, rank: Rank.Two)
        let cardString1 = cardToString(card:c1)
        let cardString2 = cardToString(card:c2)
        card1.image = UIImage(named: cardString1)
        card2.image = UIImage(named: cardString2)
        
        //updates variables
        inPersonPlayer.card1 = c1
        inPersonPlayer.card2 = c2
        inPersonPlayer.inHand = "true"
        for i in stride(from: 0, through: inPersonPlayers.count - 1, by: 1) {
            if inPersonPlayers[i]["isHost"] == "true" {
                inPersonPlayers[i]["card1"] = cardString1
                inPersonPlayers[i]["card2"] = cardString2
                inPersonPlayers[i]["inHand"] = "true"
            }
        }
        let ref = Database.database().reference()
        ref.child(inPersonRm.roomCode).child("roomPlayers").setValue(inPersonPlayers)
    }
    
    
}
