//
//  AppDelegate.swift
//  Poker Trial 3
//
//  Created by Ronnak Saxena on 6/13/20.
//  Copyright © 2020 Ronnak Saxena & Sam Meyerowitz. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    //function to delete room when time elapses
    @objc func deleteRoom() -> Void {
        print("tries to delete")
        let ref = Database.database().reference()
        ref.child(inPersonRm.roomCode).removeValue()
    }
    //timer for room
    var timer = Timer()
    func startTimer(){
        print("called startTimer")
        //change back to 3600!!
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.deleteRoom), userInfo: nil, repeats: false)
    }

    func resetTimer(){

        timer.invalidate()
        startTimer()
    }
    
    func invalidate() {
        timer.invalidate()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        
        /*if inPersonPlayer.isHost == "true" {
            startTimer()
            print("starts timer")
        }
        print("got here")*/
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        /*if inPersonPlayer.isHost == "true" {
            invalidate()
        }
        print("get here")*/
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
}

