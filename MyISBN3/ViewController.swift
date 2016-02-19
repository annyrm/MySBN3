//
//  ViewController.swift
//  MyISBN3
//
//  Created by León Felipe Guevara Chávez on 2016-02-19.
//  Copyright © 2016 León Felipe Guevara Chávez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var isbn: UITextField!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autores: UILabel!
    @IBOutlet weak var portada: UIImageView!
    @IBOutlet weak var botonBuscar: UIButton!
    @IBOutlet weak var botonAgregar: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if activeBook == -1 {
            // Add a new book to the library
            isbn.enabled = true
            botonAgregar.enabled = true
            botonBuscar.enabled = true
        }
        else {
            // Show current book's information
            isbn.enabled = false
            botonAgregar.enabled = false
            botonBuscar.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

