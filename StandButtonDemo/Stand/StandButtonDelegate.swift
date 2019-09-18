//
//  StandButtonDelegate.swift
//  StandButtonDemo
//
//  Created by Diego on 2019/8/8.
//  Copyright © 2019 whatzwhat. All rights reserved.
//

import Foundation

protocol StandButtonDelegate {
    
    func numberOfCells(in button: StandButton) -> Int
    
    func standButton(_ button: StandButton, iconInCell cell: Int) -> String
    
    func standButton(_ button: StandButton, didSelectCellAt index: Int)
    
    func standButton(_ button: StandButton, unfold: Bool)

}
