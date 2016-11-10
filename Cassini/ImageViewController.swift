//
//  ImageViewController.swift
//  Cassini
//
//  Created by Cristina Rodriguez Fernandez on 7/7/16.
//  Copyright © 2016 CrisRodFe. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    //Modelo
    var imageURL: URL?
    {
        didSet {
            image = nil
            
            //Coge la imagen de la URL y la asigna a la variable image de tipo UIImage
            //Pero solo queremos que descargue la imagen si nuestra view está mostrandose en la pantalla
            if view.window != nil {
                fetchImage()
            }
        }

    }
    
    //Crearemos nuestra ImageView con código
    fileprivate var imageView = UIImageView()
    
    //Vamos a configurar nuestra ImageView. 
    //Le tenemos que poner una imagen al imageView y reseter el marco para que quepa la imagen que le hemos puesto.
    fileprivate var image: UIImage?
    {
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            
            //Ademas tenemos que configurar el contentSize para que funcione el scrollView
            scrollView?.contentSize = imageView.frame.size
            
            spinner?.stopAnimating()
        }
        
        get{
            return imageView.image
        }
    }
    
    //Este método va a mirar en el NSURL?, ya sea en internet o en archivos locales.
    fileprivate func fetchImage()
    {
        if let url = imageURL
        {
            spinner?.startAnimating()
            //Queremos hacerlo con multihilo
            //Como el ultimo argumento es una closure lo podemos poner fuera del paréntesis sino pondriamos:
            //dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {closure})
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async
            {
                let contentsOfURL = try? Data(contentsOf: url)
                
                //Como queremos que tenga lugar en la main queue....
                DispatchQueue.main.async
                {
                    if url == self.imageURL //Nos aseguramos que la url donde vamos a buscar la foto es la misma que se nos ha pedido
                                       //Es por si se le da a un boton detras de otro antes de que se cargue la imagen
                    {
                        if let imageData = contentsOfURL //Si no es nil... cogemos los datos del url del modelo
                        { //Coge los bits de una url
                            self.image = UIImage(data: imageData) //Inicializador de UIImage
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    }
                    else
                    {
                        print("Ignored data returned from url\(url)")
                    }
                }
            }

        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    {
        didSet {
            scrollView.contentSize = imageView.frame.size
            
            //Además de ScrollView queremos que en nuestra imagen podamos hacer zoom.
            //Para ello necesitamos configurarnos como el delegate del scrollview
            //Basicamente le decimos que pregunte aqui cualquier pregunta que le surja(que hago si hacen el gesto X en la pantalla?)
            //Como self es ImageViewController y es diferentes de ScrollViewController del .delegate tenemos que hacer que nuestro controlador herede de ScrollViewDelegate, todos sus metodos/propiedades son opcionales
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    //Pero si queremos implementar el metodo del Zoom
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return imageView
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
  
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if image == nil
        {
            fetchImage()
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Añadimos nuestra imagen que hemos creado a la vista. 
        //"view" es la variable que se refiera a la vista completa, la de jerarquía más superior, en este caso es la pantalla entera.
        //view.addSubview(imageView)
        
        //Pero queremos recorrer la imagen asique la añadimos a nuestra scrollView no a la pantlla vacía.
        scrollView.addSubview(imageView)
        
        //Configuramos nuestro modelo. Como .Stanford es un string NSURL nos construye una url a partir de un string
        //imageURL = NSURL(string: DemoURL.Stanford) Esto lo usabamos antes de poner los botones para elegir una u otra foto
        //Por defecto esto nos dará un error al cargar la fuente http,por no ser segura, tenemos que configurar esto a traves del archivo Info.plist. Boton derecho, add Row -> App Transport Security Settings -> add Allow Arbitrary Loads -> YES
    }
}
