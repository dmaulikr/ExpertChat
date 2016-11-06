//
//  ChooseExpertViewController.swift
//  HuskieHackiOSVersion
//
//  Created by Rohan Daruwala on 11/5/16.
//  Copyright © 2016 Rohan Daruwala. All rights reserved.
//

import UIKit
import Parse
import Firebase
import CoreData

class ChooseExpertViewController: UIViewController {
    
    var user:PFUser!
    let defaults = UserDefaults.standard
    var numKey:Int?
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var expertButton1: UIButton!
    @IBOutlet weak var expertButton2: UIButton!
    @IBOutlet weak var indicatorIcon: UIActivityIndicatorView!
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    @IBOutlet weak var waitingMessage: UILabel!
    var isDone:Bool?
    var done:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRApp.configure()
        isDone = false
        done = false
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let err:Error = error {
                print(err.localizedDescription)
                return
            }
        })
        numKey = defaults.object(forKey: "key") as? Int
        numKey = numKey! + 1
        defaults.set(numKey, forKey: "key")
        defaults.synchronize()
        
        let configuration = Config()
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = configuration.ParseID
            ParseMutableClientConfiguration.clientKey = "fab"
            ParseMutableClientConfiguration.server = configuration.ParseServer
        })
        
        Parse.initialize(with: parseConfiguration)
        
        indicatorIcon.isHidden = true
        waitingMessage.isHidden = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onAmExpertButtonTap(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Enter Expertise", message: "What is your expertise?", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if(textField.text != "" && textField.text != nil){
                var expertList:[String] = self.user.object(forKey: "expert") as! [String]
                expertList.append(textField.text!)
                self.user.setObject(expertList, forKey: "expert")
                self.user.saveInBackground()
                let alert2 = UIAlertController(title: "Expertise Submitted", message:
                    "Expertise submitted. You will be contacted if someone requires you. Please stay on this page.", preferredStyle: UIAlertControllerStyle.alert)
                alert2.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alert2, animated: true, completion: { 
                    self.indicatorIcon.isHidden = false
                    self.indicatorIcon.startAnimating()
                    self.waitingMessage.isHidden = false
                    self.labelOne.isHidden = true
                    self.expertButton1.isHidden = true
                    self.expertButton2.isHidden = true
                    //var timer5 : Timer = Timer(timeInterval: 5.0, target: self, selector: Selector("checkStatus"), userInfo: textField.text!, repeats: true)
                    //self.checkStatus(timer: timer5)
                    self.checkStatus()
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func onNeedExpertButtonTap(_ sender: AnyObject) {
        var toShow = true
        let alert = UIAlertController(title: "Enter Expertise", message: "What expertise do you require?", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if(textField.text != "" && textField.text != nil){
                let query = PFQuery(className: "_User")
                query.whereKeyExists("expert")
                query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                    if error == nil {
                        if((objects?.count)! > 0){
                            var i = 0
                            while(i < (objects?.count)!){
                                let expertises:[String] = objects![i].object(forKey: "expert") as! [String]
                                var j = 0
                                while(j < expertises.count){
                                    if(expertises[j] == textField.text!){
                                        var check = objects![i].object(forKey: "readyTalk")
                                        check = true
                                        objects![i].setObject(check, forKey: "readyTalk")
                                        objects![i].saveInBackground()
                                        self.isDone = true
                                        self.performSegue(withIdentifier: "toChat", sender: self)
                                        toShow = false
                                    }
                                    j += 1
                                }
                                i += 1
                                
                            }
                        }
                        if(toShow){
                        let alert2 = UIAlertController(title: "Searching for Expertise", message:
                            "Request submitted. You will be contacted if there is a match. Please stay on this page.", preferredStyle: UIAlertControllerStyle.alert)
                        alert2.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alert2, animated: true, completion: {
                            self.indicatorIcon.isHidden = false
                            self.indicatorIcon.startAnimating()
                            self.waitingMessage.isHidden = false
                            self.labelOne.isHidden = true
                            self.expertButton1.isHidden = true
                            self.expertButton2.isHidden = true
                            //var timer6 : Timer = Timer(timeInterval: 5.0, target: self, selector: Selector("searchForMatch:"), userInfo: textField.text!, repeats: true)
                            //self.searchForMatch(timer: timer6
                            if(!self.isDone!){
                            self.searchForMatch(p: textField.text!)
                            }
                        })
                    }
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func searchForMatch(p:String){
        let query = PFQuery(className: "_User")
        query.whereKeyExists("expert")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if((objects?.count)! > 0){
                    var i = 0
                    while(i < (objects?.count)!){
                        let expertises:[String] = objects![i].object(forKey: "expert") as! [String]
                        var j = 0
                        while(j < expertises.count){
                            if(expertises[j] == p){
                                self.isDone = true
                                let toSave = objects![i] as! PFUser
                                toSave.setObject(true, forKey: "readyTalk")
                                toSave.setObject("YO", forKey: "NICE")
                                toSave.saveInBackground()
                                let newUser = PFUser()
                                newUser.username = String(describing: self.numKey)
                                newUser.password = "999"
                                newUser.signUpInBackground {
                                    (success, error) -> Void in
                                    if let error = error {
                                        if let errorString = (error as NSError).userInfo["error"] as? String {
                                            NSLog(errorString);
                                        }
                                    } else {
                                        // Hooray! Let them use the app now.
                                        NSLog("Signed up!");
                                        
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                                    self.performSegue(withIdentifier: "toChat", sender: self)
                                })
                                
                            }
                            j += 1
                        }
                        i += 1
                    }
                }
                if(!self.isDone!){
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                    self.searchForMatch(p: p)
                })
                }
            }
        }
    }
    
    func checkStatus(){
        let status = user.object(forKey: "readyTalk") as! Bool
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            let query = PFQuery(className: "_User")
            query.whereKey("username", equalTo: String(describing: self.numKey))
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    if(objects?[0] != nil || self.user.object(forKey: "NICE") as? String == "YO"||status == true){
                        self.user.setObject(false, forKey: "readyTalk")
                        self.user.saveInBackground()
                        self.done = true
                        self.performSegue(withIdentifier: "toChat", sender: self)
                    }
                    if(!self.done!){
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                        self.checkStatus()
                    })
                    }
                }
            }
            
        })
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toChat" && PFUser.current() != nil){
            let destination = segue.destination as! ChatViewController
            destination.senderDisplayName = user.object(forKey: "username") as! String!
            destination.channel = Channel(id: "1", name: "Expert Chat")
            destination.channelRef = channelRef.child("Channel" + String(describing: numKey))
            destination.senderId = FIRAuth.auth()?.currentUser?.uid
        }
    }
 

}
