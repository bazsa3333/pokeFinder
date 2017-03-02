//
//  Pokemon.swift
//  PokeFinder
//
//  Created by Németh Bálint on 2017. 03. 01..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexID: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _pokemonURL: String!
    private var _nextEvoName: String!
    private var _nextEvoID: String!
    private var _nextEvoLevel: String!
    
    var nextEvoLevel: String {
        
        if _nextEvoLevel == nil {
            
            _nextEvoLevel = ""
            
        }
        
        return _nextEvoLevel
        
    }
    
    var nextEvoID: String {
        
        if _nextEvoID == nil {
            
            _nextEvoID = ""
            
        }
        
        return _nextEvoID
        
    }
    
    var nextEvoName: String {
        
        if _nextEvoName == nil {
            
            _nextEvoName = ""
            
        }
        
        return _nextEvoName
        
    }
    
    var decription: String {
        
        if _description == nil {
            
            _description = ""
            
        }
        
        return _description
        
    }
    
    var type: String {
        
        if _type == nil {
            
            _type = ""
            
        }
        
        return _type
        
    }
    
    var defense: String {
        
        if _defense == nil {
            
            _defense = ""
            
        }
        
        return _defense
        
    }
    
    var height: String {
        
        if _height == nil {
            
            _height = ""
            
        }
        
        return _height
        
    }
    
    var weight: String {
        
        if _weight == nil {
            
            _weight = ""
            
        }
        
        return _weight
        
    }
    
    var attack: String {
        
        if _attack == nil {
            
            _attack = ""
            
        }
        
        return _attack
    }
    
    var nextEvolutionText: String {
        
        if _nextEvolutionTxt == nil {
            
            _nextEvolutionTxt = ""
            
        }
        
        return _nextEvolutionTxt
        
    }
    
    var name: String {
        
        return _name
        
    }
    
    var pokedexID: Int {
        
        return _pokedexID
        
    }
    
    init(name: String, pokedexID: Int) {
        
        self._name = name
        self._pokedexID = pokedexID
        
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexID)/"
        
    }
    
    func downloadPokemonDetail(completed: @escaping DownloadComplete) {
        
        Alamofire.request(_pokemonURL).responseJSON(completionHandler: { (response) in
            
            print(response.result)
            
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                
                if let weight = dict["weight"] as? String {
                    
                    self._weight = weight
                    
                }
                
                if let height = dict["height"] as? String {
                    
                    self._height = height
                    
                }
                
                if let attack = dict["attack"] as? Int {
                    
                    self._attack = "\(attack)"
                    
                }
                
                if let defense = dict["defense"] as? Int {
                    
                    self._defense = "\(defense)"
                    
                }
                
                print(self._weight)
                print(self._height)
                print(self._attack)
                print(self._defense)
                
                if let types = dict["types"] as? [Dictionary<String, String>], types.count > 0 {
                    
                    if let name = types[0]["name"] {
                        
                        self._type = name.capitalized
                        
                    }
                    
                    //ha több mint 1 tipus van akkor...
                    if types.count > 1 {
                        
                        for x in 1..<types.count {
                            
                            if let name = types[x]["name"] {
                                
                                //fontos az unwrapp itt!!!
                                self._type! += "/\(name.capitalized)"
                                
                            }
                            
                        }
                        
                    }
                    
                    print(self._type)
                    
                } else {
                    
                    self._type = ""
                    
                }
                
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>] , descArr.count > 0 {
                    
                    if let url = descArr[0]["resource_uri"] {
                        
                        let descURL = "\(URL_BASE)\(url)"
                        
                        Alamofire.request(descURL).responseJSON(completionHandler: { (response) in
                            
                            if let descDict = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let description = descDict["description"] as? String {
                                    
                                    //modositunk egy szot az adatba mert hibas
                                    let newDescription = description.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                    
                                    self._description = newDescription
                                    print(newDescription)
                                    
                                }
                                
                            }
                            
                            completed()
                        })
                        
                    }
                    
                } else {
                    
                    self._description = ""
                    
                }
                
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutions.count > 0 {
                    
                    if let nextEvo = evolutions[0]["to"] as? String {
                        
                        //megak nincsenek meg az adatbazisba :(
                        if nextEvo.range(of: "mega") == nil {
                            
                            self._nextEvoName = nextEvo
                            
                            if let uri = evolutions[0]["resource_uri"] as? String {
                                
                                let newStr = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                let nextEvolutionId = newStr.replacingOccurrences(of: "/", with: "")
                                
                                self._nextEvoID = nextEvolutionId
                                
                                if let lvlExist = evolutions[0]["level"] {
                                    
                                    if let lvl = lvlExist as? Int {
                                        
                                        self._nextEvoLevel = "\(lvl)"
                                        
                                    }
                                    
                                } else {
                                    
                                    self._nextEvoLevel = ""
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                print(self.nextEvoID)
                print(self.nextEvoName)
                print(self.nextEvoLevel)
                
            }
            completed()
            
        })
        
    }
    
}
