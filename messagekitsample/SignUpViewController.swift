//
//  SignUpViewController.swift
//  messagekitsample
//
//  Created by tatsumi kentaro on 2018/03/21.
//  Copyright © 2018年 tatsumi kentaro. All rights reserved.
//

import UIKit
import  Firebase
class SignUpViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var fullName: UITextField!
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignIn(_ sender: Any) {
        guard let email = email.text, let password = password.text, let fullName = fullName.text else {return}
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }else{
                self.db = Firestore.firestore()
                if let uid = Auth.auth().currentUser?.uid{
                    self.db.collection("users").document(uid).setData([
                        "email" : email,
                        "password": password,
                        "name": fullName
                        ])
                    print("success")
                    self.performSegue(withIdentifier: "gogo", sender: nil)
                }

            }
        }
    }
    
    

}
