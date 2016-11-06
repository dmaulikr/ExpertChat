//
//  ViewController.swift
//  HuskieHackiOSVersion
//
//  Created by Rohan Daruwala on 11/5/16.
//  Copyright © 2016 Rohan Daruwala. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    var isScreenUp:Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = Config()
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = configuration.ParseID
            ParseMutableClientConfiguration.clientKey = "fab"
            ParseMutableClientConfiguration.server = configuration.ParseServer
        })
        
        Parse.initialize(with: parseConfiguration)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        // Do any additional setup after loading the view, typically from a nib.
        
        isScreenUp = false
    }

    @IBAction func onLoginButtonPress(_ sender: AnyObject) {
        if(userTextField.text != "" && passTextField.text != "" && userTextField.text != nil && passTextField.text != nil){
            
            PFUser.logInWithUsername(inBackground: userTextField.text!, password:passTextField.text!) {
                (user, error) -> Void in
                
                if error == nil {
                    if user != nil {
                        self.performSegue(withIdentifier: "choose", sender: self)
                        
                    } else {
                        // No, User Doesn't Exist
                        print("logIn() - User Doesn't Exist")
                    }
                } else {
                    print("Nuuu")
                }
                
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "choose" && PFUser.current() != nil){
            let destination = segue.destination as! ChooseExpertViewController
            destination.user = PFUser.current()
        }
    }
    
    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Moves the screen when keyboard is opened and closed
     **/
    func keyboardWillShow(_ notification: NSNotification) {
        if(!isScreenUp){
            self.view.frame.origin.y -= 100
            isScreenUp = true
        }
    }
    func keyboardWillHide(_ notification: NSNotification) {
        if(isScreenUp == true){
            self.view.frame.origin.y += 100
            isScreenUp = false
        }
    }


}

