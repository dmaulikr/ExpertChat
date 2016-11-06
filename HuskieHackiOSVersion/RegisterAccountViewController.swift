//
//  RegisterAccountViewController.swift
//  HuskieHackiOSVersion
//
//  Created by Rohan Daruwala on 11/5/16.
//  Copyright © 2016 Rohan Daruwala. All rights reserved.
//

import UIKit
import Parse

class RegisterAccountViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
        PFUser.registerSubclass()
        //NotificationCenter.default.addObserver(self, selector: #selector(RegisterAccountViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        //NotificationCenter.default.addObserver(self, selector: #selector(RegisterAccountViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        // Do any additional setup after loading the view.
        
        isScreenUp = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    
    @IBAction func onRegisterButtonTap(_ sender: AnyObject) {
        
        if(usernameTextField.text != "" && passwordTextField.text != "" && usernameTextField.text != nil && passwordTextField.text != nil){
            let newUser = PFUser()
            newUser.username = usernameTextField.text
            newUser.password = passwordTextField.text
            let expertList:[String] = [""]
            let readyToTalk:Bool = false
            newUser.setObject(expertList, forKey: "expert")
            newUser.setObject(readyToTalk, forKey: "readyTalk")
            
            
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
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
