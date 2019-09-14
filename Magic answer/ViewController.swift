//
//  ViewController.swift
//  Magic answer
//
//  Created by Antony on 13.09.19.
//  Copyright © 2019 Antony. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

public var addedAnswers = [String]()
public var hardcodedAnswers = [String]()
public var keyAddedAnswers = "Key added answers"
public var answerTextField: UITextField!

class ViewController: UIViewController{
    
    @IBOutlet weak var labelAnswer: UILabel!
    @IBAction func addWord(_ sender: Any){
        
        let settingsAlert = UIAlertController(title: "Enter your answer", message: nil, preferredStyle: .alert)
        settingsAlert.addTextField{
                
                (textFiled) in
                textFiled.placeholder = ""
                answerTextField = textFiled
        }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in}
        let alertActionCreate = UIAlertAction(title: "Create", style: .default) { (alert) in
            
            let newText = answerTextField.text
            if (newText?.isEmpty)! {
            
                self.labelAnswer.text = "You entered nothing,shake and repeat"
            }
            else {
                
                addedAnswers.append(newText!)
                UserDefaults.standard.setValue(addedAnswers, forKey: keyAddedAnswers)
                UserDefaults.standard.synchronize()
            }
        }
        settingsAlert.addAction(alertActionCancel)
        settingsAlert.addAction(alertActionCreate)
        present(settingsAlert, animated: true, completion: nil)
    }
    public class ReachabilityTest{
        
        class func isConnectedToNetwork() -> Bool{
            
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress){
                
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags){
                
                return false
            }
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            return (isReachable && !needsConnection)
        }
    }
    
    public func getAnswerFromUrl(){
        
        guard let url = URL(string: "https://8ball.delegator.com/magic/JSON/question_string") else {return}
        let session = URLSession.shared
        let task = session.dataTask(with: url){ (data, response, error) in
            if error != nil{
                
                self.getAnswerFromLib()
            }
            else{
                
                if let content = data{
                    
                    do{
                        
                        let json = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        if let magic = json["magic"] as? NSDictionary{
                            
                            DispatchQueue.main.async(execute:{
                                    
                                    if let answer = magic["answer"]! as? String{
                                        
                                        self.labelAnswer.text = answer
                                    }
                            })
                        }
                    }
                    catch{
                        
                        self.getAnswerFromLib()
                    }
                }
            }
        }
        task.resume()
    }
    
    public func getAnswerFromLib(){
        
        UserDefaults.standard.object(forKey: keyAddedAnswers)
        let path = Bundle.main.path(forResource: "LibAnswer", ofType: "plist")
        hardcodedAnswers = NSArray(contentsOfFile: path!) as! [String]
        hardcodedAnswers += addedAnswers
        let randomAnswer = arc4random_uniform(UInt32(hardcodedAnswers.count))
        let quoteString = hardcodedAnswers[Int(randomAnswer)]
        self.labelAnswer.text = quoteString
    }
    
        override func motionEnded(_ motion: UIEventSubtype, with  event: UIEvent?){
        
        if event?.subtype == UIEventSubtype.motionShake{
            
            if ReachabilityTest.isConnectedToNetwork(){
                
                getAnswerFromUrl()
            }
            else{
                
                getAnswerFromLib()
            }
        }
    }
    override func viewDidLoad(){
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning(){
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

