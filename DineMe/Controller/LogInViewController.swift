//
//  ViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-01.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text else {fatalError()}
        guard let password = passwordTextField.text else {fatalError()}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                print(error!)
            } else {
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

