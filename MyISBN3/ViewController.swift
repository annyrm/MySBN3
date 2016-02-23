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
            let book = books[activeBook] 
            
            isbnNormal = book.valueForKey("isbn") as! String
            autoresLibro = book.valueForKey("authors") as! String
            tituloLibro = book.valueForKey("title") as! String
            portadaChica = book.valueForKey("cover_s") as! String
            portadaMediana = book.valueForKey("cover_m") as! String
            
            mostrarInformacion()
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
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Book", inManagedObjectContext: context)
        
        fetchRequest.entity = entityDescription
        fetchRequest.returnsObjectsAsFaults = false
        
        let resultsPredicate = NSPredicate(format: "isbn = %@", isbnNormal)
        fetchRequest.predicate = resultsPredicate
        
        do {
            let results : NSArray = try context.executeFetchRequest(fetchRequest)
            if results.count != 0 {
                let alert = UIAlertController(title: "Oops", message: "Ya habías agregado este libro", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
                
                self.botonAgregar.enabled = false
            } else {
                let newBook = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: context)
                
                newBook.setValue(isbnNormal, forKey: "isbn")
                newBook.setValue(tituloLibro, forKey: "title")
                newBook.setValue(autores.text, forKey: "authors")
                newBook.setValue(portadaChica, forKey: "cover_s")
                newBook.setValue(portadaMediana, forKey: "cover_m")
                
                do {
                    try newBook.managedObjectContext?.save()
                    
                    let alert = UIAlertController(title: "Listo", message: "Has agregado el libro a tu colección", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    self.botonAgregar.enabled = false
                } catch {
                    let alert = UIAlertController(title: "Oops", message: "El libro no pudo ser agregado", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }
        } catch {
            let alert = UIAlertController(title: "Oops", message: "Verifica que tengas conexión", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func buscarISBN() {
        let urlBase : String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        var cargarDatos : Bool = false
        let myISBN : String? = isbn.text!
        
        isbn.resignFirstResponder()
        
        isbnNormal = myISBN!
        isbnNormal = myISBN!.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
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
                tituloLibro = dict2["title"] as! NSString as String
                let autoresArray = dict2["authors"] as! NSArray
                for autorLibro in autoresArray {
                    let autorTemp = (autorLibro as! NSDictionary)["name"] as! String
                    autoresLibro += autorTemp
                    autoresLibro += "; "
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
            
            /* 978-0-7653-2594-5 */
        }
        
        if cargarDatos {
            botonAgregar.enabled = true
            mostrarInformacion()
        }
    }
    
    func mostrarInformacion() {
        isbn.text = isbnNormal
        titulo.text = tituloLibro
        if (autoresLibro != "") {
            autores.text = "Escrito por: " + autoresLibro
        } else {
            autores.text = "Sin autor registrado"
        }
        
        if portadaMediana != "" {
            let urlImage = NSURL(string: portadaMediana)
            let datos = NSData(contentsOfURL: urlImage!)
            if datos != nil {
                portada.image = UIImage(data: datos!)
            } else {
                portada.image = UIImage(named: "sin_portada.png")
            }
        } else {
            portada.image = UIImage(named: "sin_portada.png")
        }
    }

    // Esta función me permite ocultar el teclado una vez que toco mi pantalla fuera del campo de texto.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Esta función también me ayuda a ocultar el teclado
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        isbn.resignFirstResponder()
        buscarISBN()
        return true
    }

}

