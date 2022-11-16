//
//  InterfaceController.swift
//  StoryboardWatchApp WatchKit Extension
//
//  Created by Benoit Briatte on 21/09/2022.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    @IBAction func handleBombButton() {
        guard WCSession.default.isReachable else {
            return
        }
        WCSession.default.sendMessage(["Move" : "BOMB"], replyHandler: nil)
    }
    @IBAction func handleDownButton() {
        guard WCSession.default.isReachable else {
            return
        }
        WCSession.default.sendMessage(["Move" : "DOWN"], replyHandler: nil)
    }
    @IBAction func handleRightButton() {
        guard WCSession.default.isReachable else {
            return
        }
        WCSession.default.sendMessage(["Move" : "RIGHT"], replyHandler: nil)
    }
    @IBAction func handleLeftButton() {
        guard WCSession.default.isReachable else {
            return
        }
        WCSession.default.sendMessage(["Move" : "LEFT"], replyHandler: nil)
    }
    @IBAction func handleUpButton() {
        guard WCSession.default.isReachable else {
            return
        }
        WCSession.default.sendMessage(["Move" : "UP"], replyHandler: nil)
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch : \(activationState), \(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message)
        replyHandler(["out" : message["say"] ?? ""])
    }
    
    
}
