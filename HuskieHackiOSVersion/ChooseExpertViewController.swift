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

class ChooseExpertViewController: UIViewController {
    
    var user:PFUser!

    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var expertButton1: UIButton!
    @IBOutlet weak var expertButton2: UIButton!
    @IBOutlet weak var indicatorIcon: UIActivityIndicatorView!
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    @IBOutlet weak var waitingMessage: UILabel!
    var isDone:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRApp.configure()
        isDone = false
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let err:Error = error {
                print(err.localizedDescription)
                return
            }
        })
        
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
                                objects![i].setObject(true, forKey: "readyTalk")
                                self.performSegue(withIdentifier: "toChat", sender: self)
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
        if(status == true){
            user.setObject(false, forKey: "readyTalk")
            self.performSegue(withIdentifier: "toChat", sender: self)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.checkStatus()
        })
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toChat" && PFUser.current() != nil){
            let destination = segue.destination as! ChatViewController
            destination.senderDisplayName = user.object(forKey: "username") as! String!
            destination.channel = Channel(id: "1", name: "Channel2")
            destination.channelRef = channelRef.child("Channel2")
            destination.senderId = FIRAuth.auth()?.currentUser?.uid
        }
    }
 

}
