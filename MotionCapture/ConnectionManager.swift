//
//  ConnectionManager.swift
//  MotionCapture
//
//  Created by Mateus Reckziegel on 8/12/15.
//  Copyright (c) 2015 Mateus Reckziegel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol ConnectionManagerDelegate {
    
    func didConnectToDevice(connectionManager:ConnectionManager, device:String)
    
}

class ConnectionManager:NSObject {
   
    private let serviceType = "motion-app"
    private let myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let advertiser:MCNearbyServiceAdvertiser
    var delegate:ConnectionManagerDelegate?
    lazy var session:MCSession = {
        
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session?.delegate = self
        return session
        
    }()
    
    override init() {
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: nil, serviceType: self.serviceType)
        super.init()
        self.advertiser.delegate = self
        self.advertiser.startAdvertisingPeer()
        
    }
    
    func sendData(data:NSData!){
        
        if self.session.connectedPeers.count > 0 {
            var error:NSError?
            self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
            if error != nil {
                println("Houston we've got a problem (sendData)")
            }
        }
    }
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        default: return "Unknown"
        }
    }
    
}

extension ConnectionManager : MCSessionDelegate {
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("\(state.stringValue())")
        
        switch state {
        case .Connected:
            self.delegate?.didConnectToDevice(self, device: session.connectedPeers.map({$0.displayName})[0] as String)            
        default:
            print("")
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        certificateHandler(true)
    }
    
}

extension ConnectionManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        println("didReceiveInvitationFromPeer: \(peerID)")
        invitationHandler(true, self.session)
    }
    
}
