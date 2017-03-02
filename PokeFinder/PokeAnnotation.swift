//
//  PokeAnnotation.swift
//  PokeFinder
//
//  Created by Németh Bálint on 2017. 02. 27..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import Foundation
import MapKit


class PokeAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var pokemonNumber: Int
    var pokemonName: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, pokemonNumber: Int) {
        self.coordinate = coordinate
        self.pokemonNumber = pokemonNumber
        self.pokemonName = pokemonNames[pokemonNumber - 1].capitalized
        //title part of the annotation not from my code
        self.title = self.pokemonName
    }
    
}
