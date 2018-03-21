//
//  SignUpViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-01.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
    
        guard let email = emailTextField.text else {fatalError()}
        guard let password = passwordTextField.text else {fatalError()}
        guard let confirmPassword = confirmPasswordTextField.text else {fatalError()}
        
        if password != confirmPassword {
            print("Password are not identical")
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if (error != nil) {
                    print(error!)
                } else {
                    
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                    
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
