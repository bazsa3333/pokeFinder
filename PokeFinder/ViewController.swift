//
//  ViewController.swift
//  PokeFinder
//
//  Created by Németh Bálint on 2017. 02. 27..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

public var pokemonNames = [String]()

//implementálni kell az MKMapViewDelegate + egyenlővé kell tenni a mapView-t
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MyProtocol {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    var valueFromCollectionView: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        //a térkép követi a user location-ét
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        addPokemonNames()
        
        for index in pokemonNames {
            print(index)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        locationAuthStatus()
    }
    
    func addPokemonNames(){
        
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do{
            
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            //print(rows)
            
            for row in rows {
                
                let name = row["identifier"]!
                
                pokemonNames.append(name)
            }
            
        }catch let err as NSError{
            print(err.debugDescription)
        }
        
    }
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true
        } else {
            
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if let loc = userLocation.location {
            
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
            
        }
    }
    
    //saját helyzetjelző figura nem az alap kék pont
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        let annoIdentifier = "Pokemon"
        
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
            
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            
            annotationView = deqAnno
            annotationView?.annotation = annotation
            
        } else {
            
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
            
        }
        
        if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pokemonNumber)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "map"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotationView
    }
    
    func createSighting(forLocation location: CLLocation, withPokemon pokeId: Int) {
        
        geoFire.setLocation(location, forKey: "\(pokeId)")
        
    }
    
    func showSightingsOnMap(location: CLLocation) {
        
        let circleQuery = geoFire!.query(at: location, withRadius: 2.5)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            
            if let key = key, let location = location {
                
                let anno = PokeAnnotation(coordinate: location.coordinate, pokemonNumber: Int(key)!)
                
                self.mapView.addAnnotation(anno)
            }
        })
        
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: loc)
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? PokeAnnotation {
            
            let place = MKPlacemark(coordinate: anno.coordinate)
            let destination = MKMapItem(placemark: place)
            destination.name = "Pokemon Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    
    @IBAction func spotRandomPokemon(_ sender: UIButton) {
        
//        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
//        
//        let rand = arc4random_uniform(151) + 1
//
//        createSighting(forLocation: loc, withPokemon: Int(rand))
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PokePickerVC") as! PokePickerVC
        
        secondViewController.delegate = self
        
        present(secondViewController, animated: true, completion: nil)
        
    }
    
    func selectedPokemon(value: Int) {
        
        self.valueFromCollectionView = value
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        createSighting(forLocation: loc, withPokemon: self.valueFromCollectionView!)
        
    }
    
}












