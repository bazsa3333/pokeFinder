//
//  PokePickerVC.swift
//  PokeFinder
//
//  Created by Németh Bálint on 2017. 03. 01..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import UIKit

protocol MyProtocol {
    func selectedPokemon(value: Int)
}


class PokePickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pokemons = [Pokemon]()
    var filteredPokemons = [Pokemon]()
    var inSearchMode = false
    
    var delegate: MyProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        parsePokemonCSV()
        print(pokemons.count)
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PokePickerVC.dismissKeyboard))
//        
//        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//        //tap.cancelsTouchesInView = false
//        
//        view.addGestureRecognizer(tap)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func parsePokemonCSV() {
        
        //az ut csv-hez
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do{
            
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            print(rows)
            
            for row in rows {
                
                let pokeID = Int(row["id"]!)!
                let name = row["identifier"]!
                
                let poke = Pokemon(name: name, pokedexID: pokeID)
                pokemons.append(poke)
            }
            
        }catch let err as NSError{
            print(err.debugDescription)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            let poke: Pokemon!
            
            if inSearchMode {
                
                poke = filteredPokemons[indexPath.row]
                cell.configureCell(poke)
            } else {
                
                poke = pokemons[indexPath.row]
                cell.configureCell(poke)
            }
            
            return cell
            
        } else {
            
            return UICollectionViewCell()
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode {
            
            return filteredPokemons.count
        } else {
            
           return pokemons.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 105, height: 105)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var selectedPoke: Pokemon!
        var selectedPokeID: Int!
        
        if inSearchMode {
            
            selectedPoke = filteredPokemons[indexPath.row]
            selectedPokeID = selectedPoke.pokedexID
        } else {
            
            selectedPoke = pokemons[indexPath.row]
            selectedPokeID = selectedPoke.pokedexID
        }
        
        print(selectedPoke.name, selectedPokeID)
        
        delegate?.selectedPokemon(value: selectedPokeID)
        
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            view.endEditing(true)
            collectionView.reloadData()
        } else {
            
            inSearchMode = true
            
            let lower = searchBar.text?.lowercased()
            
            filteredPokemons = pokemons.filter({ $0.name.range(of: lower!) != nil })
            
            collectionView.reloadData()
        }
    }
    @IBAction func backBtnPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }

}
