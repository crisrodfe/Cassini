//
//  CassiniViewController.swift
//  Cassini
//
//  Created by Cristina Rodriguez Fernandez on 8/7/16.
//  Copyright © 2016 CrisRodFe. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController, UISplitViewControllerDelegate
{
    //Struct que almacenará las constantes String que tenemos en el StoryBoard
    fileprivate struct StoryBoard
    {
        static let ShowImageSegue = "Show Image"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == StoryBoard.ShowImageSegue
        {
            //Tenemos que conseguir el MVC hacia el que vamos a hacer el segue, y tenemos que prepararlo. 
            //Nos aseguramos que es una ImageViewController
            if let ivc = segue.destination.contentViewController as? ImageViewController
            {
                //Comprobamos que se ha mandado la accion desde un UIButton, y si es asi almacenamos el texto
                let imageName = (sender as? UIButton)?.currentTitle
                ivc.imageURL = DemoURL.NASAImageNamed(imageName) 
                ivc.title = imageName
                
            }
        }
    }
    
    //Para lanzar el Detail hemos quitado esta vez el segue y lo que hemos utilizado es una Target accion desde los botones
    //Con el segue cada vez que pulsabamos un boton se creaba un MVC sin embargo esta vez queremos que reutilice el mismo.
    //Solo lo hará así si es un iPad porque será un splitView. Para iphone lo seguiremos haciendo con segue, lo indicamos con código en el else, además como hemos quitado los segues que creamos en el storyboard desde cada boton, al llamar al segue desde codigo tenemos que crear un segue en el sotryboard desde el propio View (icono cuadrado amarillo)
    @IBAction func showImage(_ sender: UIButton)
    {
        if let ivc = splitViewController?.viewControllers.last?.contentViewController as? ImageViewController
        {
            let imageName = sender.currentTitle
            ivc.imageURL = DemoURL.NASAImageNamed(imageName)
            ivc.title = imageName
        }else{
            performSegue(withIdentifier: StoryBoard.ShowImageSegue, sender: sender)
        }
    }
    
    
    //Para que al abrirse la aplicación la pantalla que aparezca sea la de los botones, tenemos que usar la delegación. En primer lugar tenemos que hacer que nuestro CassiniViewController sea el delegate del split view en el que está funcionando
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool
    {
        if primaryViewController.contentViewController == self
        {
            if let ivc = secondaryViewController.contentViewController as? ImageViewController , ivc.imageURL == nil
            {
                return true
            }
        }
        return false
    }
}

//Como hemos metido el scrollView en un NavigationController el prepareSegue de antes no funcionará
//Por eso construiremos la siguiente extension
extension UIViewController
{
    var contentViewController: UIViewController
    {
        //Si soy un NavigationController
        if let navcon = self as? UINavigationController
        {
            return navcon.visibleViewController ?? self
        }
        else
        {
            return self
        }
    }
}



