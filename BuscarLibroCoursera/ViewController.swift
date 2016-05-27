//
//  ViewController.swift
//  BuscarLibroCoursera
//
//  Created by Juan Jose Renteria on 25/05/16.
//  Copyright © 2016 Juan Jose Renteria. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    
    @IBOutlet weak var barraBusqueda: UISearchBar!
    
    @IBOutlet weak var tituloLibro: UILabel!
    
    @IBOutlet weak var autoresText: UITextView!
    
    @IBOutlet weak var imagenLibro: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoresText.text = nil
        tituloLibro.text = nil
    }
    
    func limpiarGui() {
        tituloLibro.text = nil
        autoresText.text = nil
        imagenLibro.image = UIImage(named: "sin_portada.png")
    }

    // MARK: UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            limpiarGui()
        }
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        buscarLibro(searchBar.text)
    }
    
    //Efectua la busqueda por ISBN
    func buscarLibro(isbn: String?) {
        NSLog("buscarLibro")
        var msgError = ""
        var autores = ""
        
        limpiarGui()
        
        if isbn != nil {
       
            let urlConsulta = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=\(isbn!)"
            let url = NSURL(string: urlConsulta )
            let datos = NSData(contentsOfURL: url!)
            if datos != nil {
                do {
                    
                    let cadena = String(data: datos!, encoding: NSUTF8StringEncoding)

                    let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: .MutableLeaves)
                    let llave = "\(isbn!)"
                    
                    let ok = NSJSONSerialization.isValidJSONObject(json)
                    
                    // objeto principal
                    let dicRaiz = json as! NSDictionary as NSDictionary
                    if dicRaiz.count == 0 {
                        msgError = "No se encontro información el libro"
                    } else {
                    
                    let dicLibro = dicRaiz.objectForKey( llave ) as! NSDictionary
                    
                    if dicLibro.count == 0 {

                        msgError = "No se encontro información el libro"
                        
                    } else {
                        // Asignar titulo del libro
                        if let titulo = dicLibro[ "title"] {
                            self.tituloLibro.text = titulo as! String
                        }
                        
                        // Asignar autores
                        if let listaAutores = dicLibro[ "authors" ]  {
                            
                            for autor in listaAutores as! NSArray {
                                autores += autor[ "name" ] as! String
                                autores += "\n"
                            }
                            autoresText.text = autores
                            
                        }
                        
                        // Asignar portada de libroe
                        if let portadas = dicLibro[ "cover" ] as! NSDictionary? {
                            if let url = NSURL(string: portadas["small"] as! String) {
                                let dataImage = NSData(contentsOfURL: url) 
                                imagenLibro.image = UIImage(data: dataImage!)
                                
                            }
                        }
                    }
                    }
                    
                } catch  {
                    msgError = "Ocurrio al realizar la busqueda del libro"
                }
                
                
            } else {
                msgError = "Ocurrio al realizar la busqueda del libro"
            }
            
            // mostrar mensaje de error
            if !msgError.isEmpty {
                
                let alert = UIAlertController(title: "Error", message: msgError, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            
         }
        
    }
    
}

