//
//  EditRestaurantViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-07.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import SwiftForms

class EditRestaurantViewController: UIViewController {

    var form = FormDescriptor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        form.title = "Example form"

        var section1 = FormSectionDescriptor()

        var row = FormRowDescriptor(tag: "name", rowType: .Email, title: "Email")
        section1.rows.append(row)

        row = FormRowDescriptor(tag: "pass", rowType: .Password, title: "Password")
        section1.rows.append(row)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
