//
//  ViewController.swift
//  MotionCapture
//
//  Created by Mateus Reckziegel on 8/12/15.
//  Copyright (c) 2015 Mateus Reckziegel. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    var active = false
    let connectionManager = ConnectionManager()
    let cmManager = CMMotionManager()
    var motionTrack = false
    var motionQueue = NSOperationQueue.mainQueue()
    var c = 0
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var sldTime: UISlider!
    
    @IBOutlet weak var lblData: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectionManager.delegate = self
        self.sldTime.maximumValue = 1.0
        self.sldTime.minimumValue = 0.01
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    @IBAction func didPressSendData(sender: AnyObject) {
        let btn = sender as! UIButton
        self.active = !self.active
        
        
        if self.active {
            
            self.cmManager.deviceMotionUpdateInterval = NSTimeInterval(self.sldTime.value)
            
            self.cmManager.startDeviceMotionUpdatesToQueue(self.motionQueue, withHandler: {(data, error) in
            
                let a = data.userAcceleration
                let acc = [Float(self.c), Float(a.x), Float(a.y), Float(a.z)]
                
                let g = data.attitude
                let rot = [Float(g.roll), Float(g.pitch), Float(g.yaw)]
                
                println(rot)
                
//                var length:Int = 0
//                
//                for i in acc {
//                    length = length + sizeof(i.dynamicType)
//                }
                
                let data = NSData(bytes: acc, length: 16)
                
                self.connectionManager.sendData(data)
            
                self.lblData.text = String(format: "%d X %.4f  |  Y %.4f  |  Z %.4f", arguments: [self.c, a.x, a.y, a.z])
                self.c++
            })

            btn.setTitle("Stop sending motion data", forState: UIControlState.Normal)
            
        } else {
            self.c = 0
            self.cmManager.stopDeviceMotionUpdates()
            btn.setTitle("Send motion data", forState: UIControlState.Normal)
        }
        
    }
    
    @IBAction func didMoveSlider(sender: UISlider) {
        self.lblTime.text = "\(sender.value)s"
    }

}

extension ViewController : ConnectionManagerDelegate {
    
    func didConnectToDevice(connectionManager: ConnectionManager, device: String) {
        
    }
    
}