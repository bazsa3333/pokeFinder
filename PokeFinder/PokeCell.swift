//
//  PokeCell.swift
//  PokeFinder
//
//  Created by Németh Bálint on 2017. 03. 01..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import UIKit

protocol PokeCellDelegate {
    func didCellBtnTapped(cell: PokeCellDelegate)
}

class PokeCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    var pokemon: Pokemon!
    
    var delegate: PokeCellDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 5.0
        
    }
    
    func configureCell(_ pokemon: Pokemon) {
        
        self.pokemon = pokemon
        
        lbl.text = self.pokemon.name.capitalized
        img.image = UIImage(named: "\(self.pokemon.pokedexID)")
        
    }
    
   
}
