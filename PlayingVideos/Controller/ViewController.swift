//
//  ViewController.swift
//  PlayingVideos
//
//  Created by colorsLion2 on 28/01/19.
//  Copyright © 2019 colorsLion2. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func signInAction(_ sender: Any) {
        let login_by = UserDefaults.standard.object(forKey: "Login") as? String
        if login_by != nil{
        }else{
        GIDSignIn.sharedInstance().signIn()
        }
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            UserDefaults.standard.set("Google", forKey: "Login")
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
            let nav = UINavigationController(rootViewController: mainVC)
            self.appDelegate.window?.rootViewController = nav
        }
        else{
            print("error")
        }
    }
}

