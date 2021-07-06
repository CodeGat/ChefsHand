//
//  ViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 6/7/21.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    var session: WCSession?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlField: UITextField!
    
    @IBAction func tapSendDataToWatch(_ sender: Any){
        if let validSession = self.session, validSession.isReachable {
            let data: [String: Any] = ["iPhone": "data from phone!" as Any]
            validSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureWatchKitSession()
    }
    
    func configureWatchKitSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
}

extension ViewController: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session between watch and iPhone was deactivated")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]){
        print("got message: \(message)")
        DispatchQueue.main.async {
            if let value = message["watch"] as? String {
                self.label.text = value
            }
        }
    }
}


