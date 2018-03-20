//
//  SignInViewController.swift
//  messagekitsample
//
//  Created by tatsumi kentaro on 2018/03/21.
//  Copyright © 2018年 tatsumi kentaro. All rights reserved.
//

import UIKit
import Firebase
class SignInViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signIn(_ sender: Any) {
        guard let email = email.text, let password = password.text
            else{return}
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error{
                print(error.localizedDescription)
            }else{
                self.performSegue(withIdentifier: "go", sender: nil)
                print("success")
            }
            
        }
        
    }
    

    
    
    

}
