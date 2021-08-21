//
//  WatchConnectivityManager.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 21/8/21.
//

import Foundation
import WatchConnectivity

protocol WatchConnectivityDelegate: AnyObject {
    func recievedMessage(session: WCSession, message: [String: Any], replyHandler: (([String: Any]) -> Void)?)
}

protocol PhoneConnectivityDelegate: AnyObject {
    func recievedMessage(session: WCSession, message: [String: Any], replyHandler: (([String: Any]) -> Void)?)
}

class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()
    weak var watchDelegate: WatchConnectivityDelegate?
    weak var phoneDelegate: PhoneConnectivityDelegate?
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    private var sessionReady: Bool = false
    
    private override init(){}
    
    var validSession: WCSession? {
        #if os(iOS)
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            self.sessionReady = true
            return session
        }
        return nil
        #elseif os(watchOS)
        return session
        #endif
    }
    
    private var validReachableSession: WCSession? {
        if let session = validSession, session.isReachable {
            return session
        }
        return nil
    }
    
        
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    func isReady() -> Bool {
        return sessionReady
    }
    
    // sender
    func sendMessage(message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        print("About to send message with replyHandler: \(String(describing: replyHandler))")
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    //reciever
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        #if os(iOS)
        phoneDelegate?.recievedMessage(session: session, message: message, replyHandler: nil)
        #elseif os(watchOS)
        watchDelegate?.recievedMessage(session: session, message: message, replyHandler: nil)
        #endif
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        #if os(iOS)
        phoneDelegate?.recievedMessage(session: session, message: message, replyHandler: replyHandler)
        #elseif os(watchOS)
        watchDelegate?.recievedMessage(session: session, message: message, replyHandler: replyHandler)
        #endif
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activated with state \(activationState)")
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOSs session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iOSs session did deactivate")
    }
    #endif
}
