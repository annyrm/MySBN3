//
//  ViewController.swift
//  MyISBN3
//
//  Created by León Felipe Guevara Chávez on 2016-02-19.
//  Copyright © 2016 León Felipe Guevara Chávez. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var isbn: UITextField!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autores: UILabel!
    @IBOutlet weak var portada: UIImageView!
    @IBOutlet weak var botonBuscar: UIButton!
    @IBOutlet weak var botonAgregar: UIButton!
    
    var autoresLibro : String = ""
    var tituloLibro : String = ""
    var portadaChica : String = ""
    var portadaMediana : String = ""
    var isbnNormal : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        isbn.delegate = self
        
        botonAgregar.enabled = false
        botonBuscar.enabled = false
        isbn.enabled = false
        
        if activeBook == -1 {
            // Add a new book to the library
            isbn.enabled = true
            botonBuscar.enabled = true
        } else {
            // Show the active book's information
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buscar(sender: AnyObject) {
        isbn.resignFirstResponder()
        buscarISBN()
    }

    @IBAction func agregarLibro(sender: AnyObject) {
    }
    
    func buscarISBN() {
        let urlBase : String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        var cargarDatos : Bool = false
        let myISBN : String? = isbn.text!
        isbnNormal = myISBN!.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        isbn.text = isbnNormal
        let url = NSURL(string: urlBase + isbnNormal)
        let datos = NSData(contentsOfURL: url!)
        
        do {
            autoresLibro = ""
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let dict1 = json as! NSDictionary
            let dict1Array = dict1.allKeys
            if dict1Array.count > 0 {
                let dict1 = json as! NSDictionary
                let dict2 = dict1["ISBN:" + isbnNormal] as! NSDictionary
                self.titulo.text = dict2["title"] as! NSString as String
                let autoresArray = dict2["authors"] as! NSArray
                for autorLibro in autoresArray {
                    let autorTemp = (autorLibro as! NSDictionary)["name"] as! String
                    autoresLibro += autorTemp
                    autoresLibro += "; "
                }
                if (autoresLibro != "") {
                    self.autores.text = "Escrito por: " + autoresLibro
                } else {
                    self.autores.text = "Sin autor registrado"
                }
                let dict3 = dict2["cover"] as! NSDictionary
                let dict3Array = dict3.allKeys
                if dict3Array.count > 0 {
                    portadaChica = dict3["small"] as!NSString as String
                    portadaMediana = dict3["medium"] as!NSString as String
                } else {
                    portadaChica = ""
                    portadaMediana = ""
                }
                cargarDatos = true
                let imgURL = dict3["medium"] as!NSString as String
                let urlImage = NSURL(string: imgURL)
                let datos2 = NSData(contentsOfURL: urlImage!)
                if datos2 != nil {
                    portada.image = UIImage(data: datos2!)
                } else {
                    portada.image = nil
                }
            } else {
                let alert = UIAlertController(title: "Oops", message: "El ISBN proporcionado no existe", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
        catch _ {
            let alert = UIAlertController(title: "Oops", message: "Verifica que tengas conexión", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if cargarDatos {
            mostrarInformacion()
        }
    }
    
    func mostrarInformacion() {
        titulo.text = tituloLibro
        autores.text = autoresLibro
        
        if portadaMediana != "" {
            let urlImage = NSURL(string: portadaMediana)
            let datos = NSData(contentsOfURL: urlImage!)
            if datos != nil {
                portada.image = UIImage(data: datos!)
            } else {
                portada.image = UIImage(named: "sin_portada.png")
            }
        } else {
            portada.image = UIImage(named: "sinportada.png")
        }
        
        botonAgregar.enabled = true
    }

}

