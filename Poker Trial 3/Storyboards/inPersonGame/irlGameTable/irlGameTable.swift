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
import Firebase
import AVFoundation


//needed to use String.substring
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

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
    var suit: Suit
    var rank: Rank
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

func subArr(numbers: Array<Card>, startPosition: Int, endPosition:Int) -> Array<Card> {
    let newCards = Array(numbers[startPosition..<endPosition])
    return newCards
}

//returns the five cards making up hand
func fiveCardHand(oldHand:Hand) -> [Card] {
    let type:HandStrength = oldHand.getHand()
    var newHand:[Card] = []
    //checks which hand and return corresponding 5 card hand
    if type == HandStrength.RoyalFlush {
        var suits:[Suit:Int] = [Suit.Diamond:0, Suit.Heart:0, Suit.Spade:0, Suit.Club:0]
        for card in oldHand.cards {
            suits[card.suit]! += 1
        }
        var handSuit:Suit = Suit.Diamond
        for (key,val) in suits {
            if val >= 5 {
                handSuit = key
            }
        }
        newHand = [Card(suit: handSuit, rank: Rank.Ten), Card(suit: handSuit, rank: Rank.Jack), Card(suit: handSuit, rank: Rank.Queen), Card(suit: handSuit, rank: Rank.King), Card(suit: handSuit, rank: Rank.Ace)]
        return newHand
    }
    else if type == HandStrength.StraightFlush {
        let sortedHand = oldHand.cards.sorted(by: >)
        var suits:[Suit:Int] = [Suit.Diamond:0, Suit.Heart:0, Suit.Spade:0, Suit.Club:0]
        for card in sortedHand {
            suits[card.suit]! += 1
        }
        var handSuit:Suit = Suit.Diamond
        for (key,val) in suits {
            if val >= 5 {
                handSuit = key
                break
            }
        }
        var suitedCards:[Card] = []
        for card in sortedHand {
            if card.suit == handSuit {
                suitedCards.append(card)
            }
        }
        let numOfIterations:Int = suitedCards.count - 5
        for i in stride(from: 0, through: numOfIterations, by: 1){
            if isStraight(cards: subArr(numbers: suitedCards, startPosition:i, endPosition: i + 5)) {
                return subArr(numbers: suitedCards, startPosition:i, endPosition: i + 5).sorted(by: >)
            }
        }
        return [Card(suit: handSuit, rank: Rank.Five), Card(suit: handSuit, rank: Rank.Four), Card(suit: handSuit, rank: Rank.Three), Card(suit: handSuit, rank: Rank.Two), Card(suit: handSuit, rank: Rank.Ace)]
    }
    else if type == HandStrength.FourOfAKind {
        var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
        for card in oldHand.cards {
            if let _:Int = pairs[card.rank]{
                pairs[card.rank]! += 1
            }
        }
        var fourCards:Rank = Rank.Two
        for (key,val) in pairs {
            if val == 4 {
                fourCards = key
                break
            }
        }
        let sortedCards = oldHand.cards.sorted(by: >)
        var highCard:Card = Card(suit: Suit.Diamond, rank: Rank.Two)
        for i in stride(from: 0, to: sortedCards.count, by: 1) {
            if sortedCards[i].rank != fourCards {
                highCard = sortedCards[i]
                break
            }
        }
        return [Card(suit: Suit.Diamond, rank: fourCards), Card(suit: Suit.Club, rank: fourCards), Card(suit: Suit.Spade, rank: fourCards), Card(suit: Suit.Heart, rank: fourCards), highCard]
        
    }
    else if type == HandStrength.FullHouse {
        var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
        for card in oldHand.cards {
            if let _:Int = pairs[card.rank]{
                pairs[card.rank]! += 1
            }
        }
        var highestSet:Rank = Rank.Two
        var highestPair:Rank = Rank.Two
        for (key,val) in pairs {
            if val > 2 && key.rawValue > highestSet.rawValue{
                highestSet = key
            }
        }
        pairs.removeValue(forKey: highestSet)
        for (key,val) in pairs {
            if val > 1 && key.rawValue > highestPair.rawValue{
                highestPair = key
            }
        }
        var new:[Card] = []
        for card in oldHand.cards {
            if card.rank == highestSet || card.rank == highestPair{
                new.append(card)
            }
            if new.count == 5 {
                break
            }
        }
        return new
    }
    else if type == HandStrength.Flush {
        let sortedHand = oldHand.cards.sorted(by: >)
        var suits:[Suit:Int] = [Suit.Diamond:0, Suit.Heart:0, Suit.Spade:0, Suit.Club:0]
        for card in sortedHand {
            suits[card.suit]! += 1
        }
        var handSuit:Suit = Suit.Diamond
        for (key,val) in suits {
            if val >= 5 {
                handSuit = key
                break
            }
        }
        var new:[Card] = []
        for i in stride(from: 0, to: sortedHand.count, by: 1) {
            if sortedHand[i].suit == handSuit {
                new.append(sortedHand[i])
                if new.count == 5 {
                    break
                }
            }
        }
        return new
    }
    else if type == HandStrength.Straight {
        let sortedHand = oldHand.cards.sorted(by: >)
        var noPairs:[Rank:Card] = [:]
        var sortedUnique:[Card] = []
        for card in sortedHand {
            guard let _:Card = noPairs[card.rank] else {
                noPairs[card.rank] = card
                sortedUnique.append(card)
                continue
            }
        }
        let numOfIterations:Int = noPairs.count - 5
        for i in stride(from: 0, through: numOfIterations, by: 1) {
            if isStraight(cards: subArr(numbers: sortedUnique, startPosition:i, endPosition: i + 5)) {
                return subArr(numbers: sortedUnique, startPosition:i, endPosition: i + 5).sorted(by: >)
            }
        }
        let leastToGreatest:[Card] = sortedUnique.sorted(by: <)
        let new:[Card] = subArr(numbers: leastToGreatest, startPosition:0, endPosition: 4)
        var sortedNew:[Card] = new.sorted(by: >)
        sortedNew.append(leastToGreatest[leastToGreatest.count - 1])
        return sortedNew
    }
    else if type == HandStrength.ThreeOfAKind {
        var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
        for card in oldHand.cards {
            if let _:Int = pairs[card.rank]{
                pairs[card.rank]! += 1
            }
        }
        var highestSet:Rank = Rank.Two
        for (key,val) in pairs {
            if val > 2 && key.rawValue > highestSet.rawValue{
                highestSet = key
            }
        }
        let sortedHand = oldHand.cards.sorted(by: >)
        var new:[Card] = []
        for i in stride(from: 0, to: sortedHand.count, by: 1) {
            if sortedHand[i].rank != highestSet {
                new.append(sortedHand[i])
            }
            if new.count == 2 {
                break
            }
        }
        for i in stride(from: 0, to: sortedHand.count, by: 1) {
            if sortedHand[i].rank == highestSet {
                new.append(sortedHand[i])
            }
        }
        return new
    }
    else if type == HandStrength.TwoPair {
        let sortedHand = oldHand.cards.sorted(by: >)
        var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
        for card in oldHand.cards {
            if let _:Int = pairs[card.rank]{
                pairs[card.rank]! += 1
            }
        }
        var pair1:Rank = Rank.Two
        var pair2:Rank = Rank.Two
        for (key,val) in pairs {
            if val == 2 {
                pair1 = key
                pairs.removeValue(forKey: key)
                break
            }
        }
        for (key,val) in pairs {
            if val == 2 {
                pair2 = key
                break
            }
        }
        var newHand:[Card] = []
        for i in stride(from: 0, to: sortedHand.count, by: 1) {
            if sortedHand[i].rank != pair1 && sortedHand[i].rank != pair2 {
                newHand.append(sortedHand[i])
                break
            }
        }
        for i in stride(from: 0, to: sortedHand.count, by: 1) {
            if sortedHand[i].rank == pair1 || sortedHand[i].rank == pair2 {
                newHand.append(sortedHand[i])
            }
        }
        return newHand
    }
    else if type == HandStrength.Pair {
        let sortedHand = oldHand.cards.sorted(by: >)
        var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
        for card in oldHand.cards {
            if let _:Int = pairs[card.rank]{
                pairs[card.rank]! += 1
            }
        }
        var pair:Rank = Rank.Two
        for (key,val) in pairs {
            if val == 2 {
                pair = key
                break
            }
        }
        var newHand:[Card] = []
        for i in stride(from: 0, to: sortedHand.count, by: 1) {
            if sortedHand[i].rank != pair {
                newHand.append(sortedHand[i])
            }
            if newHand.count == 3 {
                break
            }
        }
        for i in stride(from: 0, to: sortedHand.count, by: 1) {
            if sortedHand[i].rank == pair {
                newHand.append(sortedHand[i])
            }
        }
        return newHand
        
    }
    else {
        newHand = oldHand.cards.sorted(by: <)
        while newHand.count > 5 {
            newHand.remove(at: 0)
        }
        return newHand
    }
}

public struct Hand {
    public let cards: [Card]
 
    public var numberOfCards: Int {
        return cards.count
    }
 
    init(cards: [Card]) {
        self.cards = cards
    }
    public static func ==(lhs: Hand, rhs: Hand) -> Bool {
           let lhsCards = fiveCardHand(oldHand: lhs).sorted(by: >)
           let rhsCards = fiveCardHand(oldHand: rhs).sorted(by: >)
    
           for (lhsCard, rhsCard) in zip(lhs.cards, rhs.cards) {
               if lhsCard.rank != rhsCard.rank {
                   return false
               }
           }
    
           return true
       }
    public func getHand() -> HandStrength {
        if isRoyalFlush(cards: cards) { return HandStrength.RoyalFlush }
        if isStraightFlush(cards: cards) { return HandStrength.StraightFlush }
        if isFourOfAKind(cards: cards) { return HandStrength.FourOfAKind}
        if isFullHouse(cards: cards) { return HandStrength.FullHouse }
        if isFlush(cards: cards) { return HandStrength.Flush }
        if isStraight(cards: cards) { return HandStrength.Straight }
        if isThreeOfAKind(cards: cards) { return HandStrength.ThreeOfAKind }
        if isTwoPair(cards: cards) { return HandStrength.TwoPair }
        if isPair(cards: cards) { return HandStrength.Pair }
        return HandStrength.HighCard
    }
}

extension Card: Comparable {
    public static func <(lhs: Card, rhs: Card) -> Bool {
        return lhs.rank.rawValue < rhs.rank.rawValue
    }
}



extension Hand: Comparable {
    public static func <(lhs: Hand, rhs: Hand) -> Bool {
        let lhsHand = lhs.getHand()
        let rhsHand = rhs.getHand()
        //compares when they're dif hands
        if lhsHand != rhsHand {
            return lhsHand.rawValue < rhsHand.rawValue
        }
        //edge case to compare A-5 straight
        if lhsHand == HandStrength.Straight || lhsHand == HandStrength.StraightFlush{
            let lhsFive = fiveCardHand(oldHand: lhs)
            let rhsFive = fiveCardHand(oldHand: rhs)
            return lhsFive[0].rank.rawValue < rhsFive[0].rank.rawValue
        }
        let lhsCards = fiveCardHand(oldHand: lhs).sorted(by: >)
        let rhsCards = fiveCardHand(oldHand: rhs).sorted(by: >)
 
        for (lhsCard, rhsCard) in zip(lhsCards, rhsCards) {
            if lhsCard.rank == rhsCard.rank { continue }
            return lhsCard < rhsCard
        }
        return false
    }
}

func isPair(cards:[Card]) ->Bool {
    var pairs:[Rank:Card] = [:]
    for card in cards {
        if let _:Card = pairs[card.rank]{
            return true
        }
        pairs[card.rank] = card
    }
    return false
}

func isTwoPair(cards:[Card]) ->Bool {
    if !isPair(cards:cards) {
        return false
    }
    var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
    for card in cards {
        if let _:Int = pairs[card.rank]{
            pairs[card.rank]! += 1
        }
    }
    var numOfPairs = 0
    for (_,value) in pairs {
        if value > 1 {
            numOfPairs = numOfPairs + 1
        }
    }
    if numOfPairs > 1 {
        return true
    }
    return false
    
}
func isThreeOfAKind(cards:[Card]) ->Bool {
    if !isPair(cards:cards) {
        return false
    }
    var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
    for card in cards {
        if let _:Int = pairs[card.rank]{
            pairs[card.rank]! += 1
        }
    }
    for (_,value) in pairs {
        if value > 2 {
            return true
        }
    }
    return false
}

func isStraight(cards:[Card]) -> Bool{
    let sortedHand = cards.sorted(by: <)
    var noPairs:[Rank:Card] = [:]
    var sortedUnique:[Card] = []
    for card in sortedHand {
        guard let _:Card = noPairs[card.rank] else {
            noPairs[card.rank] = card
            sortedUnique.append(card)
            continue
        }
    }
    if noPairs.count < 5 {
        return false
    }
    let numOfIterations:Int = noPairs.count - 5
    for j in stride(from: 0, through: numOfIterations, by: 1) {
        if sortedUnique[j].rank.rawValue + 4 == sortedUnique[j+4].rank.rawValue {
            return true
        }
    }
    if sortedUnique[sortedUnique.count - 1].rank == Rank.Ace {
        if sortedUnique[3].rank == Rank.Five {
            return true
        }
    }
    return false
    
}

func isFlush(cards:[Card]) -> Bool{
    var numHearts:Int = 0
    var numClubs:Int = 0
    var numSpades:Int = 0
    var numDiamonds:Int = 0
    for card in cards {
        if card.suit == Suit.Heart {
            numHearts = numHearts + 1
        }
        if card.suit == Suit.Club {
            numClubs = numClubs + 1
        }
        if card.suit == Suit.Spade {
            numSpades = numSpades + 1
        }
        if card.suit == Suit.Diamond {
            numDiamonds = numDiamonds + 1
        }
    }
    if (numHearts >= 5 || numClubs >= 5 || numSpades >= 5 || numDiamonds >= 5) {
        return true
    }
    return false
}

func isFullHouse(cards:[Card]) -> Bool {
    if !isThreeOfAKind(cards: cards) {
        return false
    }
    var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
    for card in cards {
        if let _:Int = pairs[card.rank]{
            pairs[card.rank]! += 1
        }
    }
    for (key,value) in pairs {
        if value > 2 {
            pairs[key] = 0
            break
        }
    }
    for (_,value) in pairs {
        if value > 1 {
            return true
        }
    }
    return false
}

func isFourOfAKind(cards:[Card]) -> Bool {
    if !isThreeOfAKind(cards: cards) {
        return false
    }
    var pairs:[Rank:Int] = [Rank.Two:0, Rank.Three:0,Rank.Four:0, Rank.Five:0,Rank.Six:0, Rank.Seven:0,Rank.Eight:0, Rank.Nine:0,Rank.Ten:0, Rank.Jack:0,Rank.Queen:0, Rank.King:0,Rank.Ace:0]
    for card in cards {
        if let _:Int = pairs[card.rank]{
            pairs[card.rank]! += 1
        }
    }
    for (_,value) in pairs {
        if value == 4 {
            return true
        }
    }
    return false
}

func isStraightFlush(cards:[Card]) -> Bool {
    if !(isFlush(cards: cards)) || !(isStraight(cards: cards)) {
        return false
    }
    let sortedHand = cards.sorted(by: <)
    var noPairs:[Rank:Card] = [:]
    var sortedUnique:[Card] = []
    for card in sortedHand {
        guard let _:Card = noPairs[card.rank] else {
            noPairs[card.rank] = card
            sortedUnique.append(card)
            continue
        }
    }
    if noPairs.count < 5 {
        return false
    }
    let numOfIterations:Int = sortedUnique.count - 5
    for j in stride(from: 0, through: numOfIterations, by: 1) {
        for k in stride(from: 0, through: 3, by: 1) {
            if k == 3 {
                if (sortedUnique[j+3].rank.rawValue == (sortedUnique[j+4].rank.rawValue - 1)) && (sortedUnique[j+3].suit == sortedUnique[j+4].suit) {
                    return true
                }
                
            }
            if (sortedUnique[j+k].rank.rawValue != (sortedUnique[j+k+1].rank.rawValue - 1)) || (sortedUnique[j+k].suit != sortedUnique[j+k+1].suit) {
                break
            }
            
        }
    }
    if sortedUnique[sortedUnique.count - 1].rank == Rank.Ace && sortedUnique[3].rank == Rank.Five {
        for i in stride(from: 0, through: 3, by: 1) {
            if sortedUnique[i].suit != sortedUnique[sortedUnique.count - 1].suit {
                break
            }
            if i == 3 {
                return true
            }
        }
    }
    return false
}

func isRoyalFlush(cards:[Card]) -> Bool {
    if !isStraightFlush(cards: cards) {
        return false
    }
    let sortedHand = cards.sorted(by: <)
    var sortedUnique:[Card] = []
    var noPairs:[Rank:Card] = [:]
    for card in sortedHand {
        guard let _:Card = noPairs[card.rank] else {
            noPairs[card.rank] = card
            sortedUnique.append(card)
            continue
        }
    }
    if sortedUnique[sortedUnique.count - 1].rank == Rank.Ace && sortedUnique[sortedUnique.count - 5].rank == Rank.Ten {
        return true
    }
    return false
}


public enum HandStrength: Int {
    case HighCard, Pair, TwoPair, ThreeOfAKind, Straight, Flush, FullHouse, FourOfAKind, StraightFlush, RoyalFlush
}

func winningHand(hands:[Hand]) -> [Card] {
    var winningHand:Hand = hands[0]
    for i in stride(from: 1, to: hands.count, by: 1) {
        if hands[i] != winningHand {
            if hands[i] > winningHand {
                winningHand = hands[i]
            }
        }
    }
    return fiveCardHand(oldHand: winningHand)
}

func stringToCard(str:String) -> Card {
    var card:Card = Card(suit: Suit.Heart, rank: Rank.Two)
    if str[0] == "2"{
        card.rank = Rank.Two
    }
    if str[0] == "3"{
        card.rank = Rank.Three
    }
    if str[0] == "4"{
        card.rank = Rank.Four
    }
    if str[0] == "5"{
        card.rank = Rank.Five
    }
    if str[0] == "6"{
        card.rank = Rank.Six
    }
    if str[0] == "7"{
        card.rank = Rank.Seven
    }
    if str[0] == "8"{
        card.rank = Rank.Eight
    }
    if str[0] == "9"{
        card.rank = Rank.Nine
    }
    if str[0] == "1"{
        card.rank = Rank.Ten
    }
    if str[0] == "J"{
        card.rank = Rank.Jack
    }
    if str[0] == "Q"{
        card.rank = Rank.Queen
    }
    if str[0] == "K"{
        card.rank = Rank.King
    }
    if str[0] == "A"{
        card.rank = Rank.Ace
    }
    if str[str.count-1] == "S"{
        card.suit = Suit.Spade
    }
    if str[str.count-1] == "C"{
        card.suit = Suit.Club
    }
    if str[str.count-1] == "H"{
        card.suit = Suit.Heart
    }
    if str[str.count-1] == "D"{
        card.suit = Suit.Diamond
    }
    return card
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

func getHandText(cardsShown:Int) -> String {
    guard let card1:Card = inPersonPlayer.card1 else{return ""}
    guard let card2:Card = inPersonPlayer.card2 else{return ""}
    var cards:[Card] = [card1, card2]
    for i in stride(from: 1, through: cardsShown, by: 1) {
        let comCard:Card = stringToCard(str: inPersonRm.comCards[i])
        cards.append(comCard)
    }
    let hand:Hand = Hand(cards: cards)
    let type = hand.getHand()
    if type == HandStrength.RoyalFlush {
        return "Royal Flush👑"
    }
    else if type == HandStrength.StraightFlush {
        return "Straight Flush🧐"
    }
    else if type == HandStrength.FourOfAKind {
        return "Four Of A Kind4️⃣"
    }
    else if type == HandStrength.FullHouse {
        return "Full House😈"
    }
    else if type == HandStrength.Flush {
        return "Flush🤧"
    }
    else if type == HandStrength.Straight {
        return "Straight🤝"
    }
    else if type == HandStrength.ThreeOfAKind {
        return "Three Of A Kind3️⃣"
    }
    else if type == HandStrength.TwoPair {
        return "Two Pair🤗"
    }
    else if type == HandStrength.Pair {
        return "Pair🙏"
    }
    return "Highcard🤡"
}

// UIImage+Alpha.swift

extension UIImage {

    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
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
    
    @IBOutlet weak var copyButton: UIButton!
    
    //deck class for dealing
    var rmDeck:Deck = Deck()
    //sounds
    var audioPlayer = AVAudioPlayer()
    let foldSound = Bundle.main.path(forResource: "foldSound", ofType: "wav")
    let dealSound = Bundle.main.path(forResource: "dealSound", ofType: "wav")
    
    //function to delete room when time elapses
    @objc func deleteRoom() -> Void {
        let ref = Database.database().reference()
        ref.child(inPersonRm.roomCode).removeValue()
    }
    //timer for room
    var timer = Timer()
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(self.deleteRoom), userInfo: nil, repeats: false)
    }

    func resetTimer(){

        timer.invalidate()
        startTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reference to server
        let ref = Database.database().reference()
        
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
        copyButton.layer.cornerRadius = 10.0
        copyButton.tintColor = UIColor.white
        copyButton.layer.borderWidth = 2.0
        copyButton.layer.borderColor = CGColor.init(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        //groups to use later
        let comCards = [flop1, flop2, flop3, turn, river]
        let names = [name1, name2, name3, name4, name5, name6, name7, name8, name9, name10]
        
        
        //screen for host
        if inPersonPlayer.isHost == "true" {
            if inPersonPlayers.count < 2 {
                settingsButton.isHidden = true
                leaveButton.isHidden = false
            }
            else {
                leaveButton.isHidden = true
                settingsButton.isHidden = false
            }
            dealButton.isHidden = true
            foldButton.isHidden = true
            waitingLabel.isHidden = true
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
            //puts everyone's names around the table
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
            //checks for folded players
            let names = [name1, name2, name3, name4, name5, name6, name7, name8, name9, name10]
            for i in stride(from: 0, to: inPersonPlayers.count, by: 1) {
                if inPersonPlayers[i]["isFolded"] == "true" {
                    for j in stride(from: 0, to: names.count, by: 1) {
                        if names[j]?.titleLabel?.text == inPersonPlayers[i]["name"] {
                            names[j]?.isHidden = true
                        }
                    }
                }
            }
        }
        
        //check if game started
        ref.child(inPersonRm.roomCode).child("gameStarted").observe(.value, with: { firDataSnapshot in
            guard let val = firDataSnapshot.value as? String else {
                return
            }
            inPersonRm.gameStarted = val
            if inPersonRm.gameStarted == "true" {
                self.waitingLabel.isHidden = true
                self.foldButton.isHidden = false
            }
        })
        
        //check community cards upon initial entry
        ref.child(inPersonRm.roomCode).child("comCards").observe(.value, with: { firDataSnapshot in
            guard let val = firDataSnapshot.value as? [String] else {
                return
            }
            inPersonRm.comCards = val
            if inPersonRm.comCards[0] != "P" {
                self.handLabel.isHidden = false
                //plays deal sound
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.dealSound!))
                }
                catch {
                    print("error")
                }
                var cardsShown:Int = 0
                if inPersonRm.comCards[0] == "F" {
                    self.handLabel.text = getHandText(cardsShown: 3)
                    cardsShown = 3
                }
                if inPersonRm.comCards[0] == "T" {
                    self.handLabel.text = getHandText(cardsShown: 4)
                    cardsShown = 4
                }
                if inPersonRm.comCards[0] == "R" {
                    self.handLabel.text = getHandText(cardsShown: 5)
                    cardsShown = 5
                }
                for i in stride(from: 0, to: cardsShown, by: 1) {
                    comCards[i]?.image = UIImage(named: inPersonRm.comCards[i+1])
                }
            }
            //new hand started
            else {
                //resets room timer
                self.resetTimer()
                
                //hides hand label and com cards
                self.handLabel.isHidden = true
                for card in comCards {
                    card?.image = UIImage(named: "back")
                }
                //unfolds everyone on table view
                for name in names {
                    name?.isHidden = true
                }
                for i in stride(from: 0, to: inPersonPlayers.count, by: 1) {
                    for j in stride(from: 0, to: names.count, by: 1) {
                        if names[j]?.titleLabel?.text == inPersonPlayers[i]["name"] {
                            names[j]?.isHidden = false
                        }
                    }
                }
                
                //displays players cards
                ref.child(inPersonRm.roomCode).child("roomPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let playersCopy = snapshot.value as? [[String:String]] else {
                        print("messed up")
                        return
                    }
                    inPersonPlayers = playersCopy
                    inPersonRm.roomPlayers = inPersonPlayers
                    for player in inPersonPlayers{
                        if player["name"] == inPersonPlayer.name && player["card1"] != "00"{
                            guard let card1Val = player["card1"] else{return}
                            inPersonPlayer.card1 = stringToCard(str: card1Val)
                            guard let card2Val = player["card2"] else{return}
                            inPersonPlayer.card2 = stringToCard(str: card2Val)
                            self.card1.image = UIImage(named: card1Val)
                            self.card2.image = UIImage(named: card2Val)
                        }
                    }
                })
            }
        })
          
        //observes if player was removed
        ref.child(inPersonRm.roomCode).child("roomPlayers").observe(.childRemoved, with: { firDataSnapshot in
            var wasRemoved:Bool = true
            ref.child(inPersonRm.roomCode).child("roomPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let playersCopy = snapshot.value as? [[String:String]] else {
                    print("messed up")
                    return
                }
                inPersonPlayers = playersCopy
                inPersonRm.roomPlayers = inPersonPlayers
                for player in inPersonPlayers {
                    if player["name"] == inPersonPlayer.name {
                        wasRemoved = false
                    }
                }
                //segues to Main if you were player removed
                if wasRemoved == true {
                    let storyboard = UIStoryboard(name: "irlGameTable", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "Main")
                    self.present(myVC, animated: true, completion: nil)
                }
                
                //updates names
                let names = [self.name1, self.name2, self.name3, self.name4, self.name5, self.name6, self.name7, self.name8, self.name9, self.name10]
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
            })
            
            //changes leave to settings when someone joins
            if inPersonPlayer.isHost == "true" && inPersonPlayers.count > 1{
                self.leaveButton.isHidden = true
                self.settingsButton.isHidden = false
            }
            else if inPersonPlayer.isHost == "true" && inPersonPlayers.count == 1{
                self.leaveButton.isHidden = false
                self.settingsButton.isHidden = true
            }
            
        })
        
        //observes players: if theres a new host or player folds
        ref.child(inPersonRm.roomCode).child("roomPlayers").observe(.childChanged, with: { firDataSnapshot in
            ref.child(inPersonRm.roomCode).child("roomPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
                let playersCopy = snapshot.value as? [[String:String]]
                //checks to see if change was new host
                for i in stride(from: 0, to: inPersonPlayers.count, by: 1) {
                    if playersCopy?[i]["name"] == inPersonPlayer.name{
                        if playersCopy?[i]["isHost"] == "true" {
                            self.leaveButton.isHidden = true
                            self.waitingLabel.isHidden = true
                            self.settingsButton.isHidden = false
                            self.handButton.isHidden = false
                            if inPersonRm.gameStarted == "true" {
                                self.dealButton.isHidden = false
                            }
                        }
                    }
                }
                //checks to see if new change was a fold
                let names = [self.name1, self.name2, self.name3, self.name4, self.name5, self.name6, self.name7, self.name8, self.name9, self.name10]
                guard let updatedPlayers = playersCopy else{return}
                for i in stride(from: 0, to: updatedPlayers.count, by: 1) {
                    if updatedPlayers[i]["isFolded"] == "true" {
                        for j in stride(from: 0, to: names.count, by: 1) {
                            if names[j]?.titleLabel?.text == updatedPlayers[i]["name"] {
                                names[j]?.isHidden = true
                            }
                        }
                    }
                }
            })

            //updates inPersonPlayers
            ref.child(inPersonRm.roomCode).child("roomPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let playersCopy = snapshot.value as? [[String:String]] else {
                    return
                }
                inPersonPlayers = playersCopy
                inPersonRm.roomPlayers = inPersonPlayers
            })
            
        })
        
        
        //observes if room was deleted
        ref.child(inPersonRm.roomCode).observe(.childRemoved, with: { firDataSnapshot in
            //segues to Main if room is deleted
            let storyboard = UIStoryboard(name: "irlGameTable", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "Main")
            self.present(myVC, animated: true, completion: nil)
        })
        
        ref.child(inPersonRm.roomCode).child("roomPlayers").observe(.value, with: { firDataSnapshot in
            guard let playersCopy = firDataSnapshot.value as? [[String:String]] else{return}
            //updates variables
            inPersonPlayers = playersCopy
            inPersonRm.roomPlayers = inPersonPlayers
            //adds name to table
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
            
            //changes leave to settings when someone joins
            if inPersonPlayer.isHost == "true" && inPersonPlayers.count > 1{
                self.leaveButton.isHidden = true
                self.settingsButton.isHidden = false
            }
            else if inPersonPlayer.isHost == "true" && inPersonPlayers.count == 1{
                self.leaveButton.isHidden = false
                self.settingsButton.isHidden = true
            }
        })
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
        
        
        //gives all players cards, updates UI, updates server, makes isFolded false
        for i in stride(from: 0, to: inPersonPlayers.count, by: 1) {
            let c1:Card = rmDeck.drawCard() ?? Card(suit: Suit.Diamond, rank: Rank.Two)
            let c2:Card = rmDeck.drawCard() ?? Card(suit: Suit.Diamond, rank: Rank.Two)
            let cardString1 = cardToString(card:c1)
            let cardString2 = cardToString(card:c2)
            inPersonPlayers[i]["card1"] = cardString1
            inPersonPlayers[i]["card2"] = cardString2
            if inPersonPlayer.name == inPersonPlayers[i]["name"] {
                card1.image = UIImage(named: cardString1)
                card2.image = UIImage(named: cardString2)
                inPersonPlayer.card1 = c1
                inPersonPlayer.card2 = c2
            }
            inPersonPlayers[i]["isFolded"] = "false"
        }
        
        //deals com cards and sets hand position to preflop
        for i in stride(from: 1, to: 6, by: 1){
            let card:Card = rmDeck.drawCard() ?? Card(suit: Suit.Diamond, rank: Rank.Two)
            inPersonRm.comCards[i] = cardToString(card: card)
        }
        inPersonRm.comCards[0] = "P"
        
        //updates server
        let ref = Database.database().reference()
        ref.child(inPersonRm.roomCode).child("roomPlayers").setValue(inPersonPlayers)
        ref.child(inPersonRm.roomCode).child("comCards").setValue(inPersonRm.comCards)
    }
    
    func getGreyImage(myImage:UIImage) -> UIImage {
        guard let currentCGImage = myImage.cgImage else { return myImage}
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")

        // set a gray value for the tint color
        filter?.setValue(CIColor(red: 0.5, green: 0.5, blue: 0.5), forKey: "inputColor")

        filter?.setValue(1.0, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return myImage}

        let context = CIContext()

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return myImage
    }
    
    
    
    @IBAction func tapFold(_ sender: Any) {
        //plays folding sound
        do {
        audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: foldSound!))
        }
        catch {
            print("error")
        }
        //make cards grey and transparent
        guard let grey1 = card1.image else {return}
        let card1Grey = getGreyImage(myImage: grey1)
        card1.image = card1Grey.alpha(0.5)
        guard let grey2 = card2.image else {return}
        let card2Grey = getGreyImage(myImage: grey2)
        card2.image = card2Grey.alpha(0.5)
        
        //update variables & server
        inPersonPlayer.isFolded = "true"
        for i in stride(from: 0, to: inPersonPlayers.count, by: 1) {
            if inPersonPlayers[i]["name"] == inPersonPlayer.name {
                inPersonPlayers[i]["isFolded"] = "true"
            }
        }
        let ref = Database.database().reference()
        ref.child(inPersonRm.roomCode).child("roomPlayers").setValue(inPersonPlayers)
        
        //update players at table
        let names = [name1, name2, name3, name4, name5, name6, name7, name8, name9, name10]
        for i in stride(from: 0, through: 9, by: 1) {
            if names[i]?.titleLabel?.text == inPersonPlayer.name {
                names[i]?.isHidden = true
            }
        }
    }
    
    
    @IBAction func tapDealButton(_ sender: Any) {
        if inPersonRm.comCards[0] == "P" {
            inPersonRm.comCards[0] = "F"
        }
        else if inPersonRm.comCards[0] == "F" {
            inPersonRm.comCards[0] = "T"
        }
        else if inPersonRm.comCards[0] == "T" {
            inPersonRm.comCards[0] = "R"
        }
        let ref = Database.database().reference()
        ref.child(inPersonRm.roomCode).child("comCards").setValue(inPersonRm.comCards)
    }
    
    
    @IBAction func tapCopyButton(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = inPersonRm.roomCode
    }
    
    
}



