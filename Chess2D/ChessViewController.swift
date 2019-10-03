//
//  ViewController.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 21/09/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import UIKit

protocol IChessViewController {
    
}

class ChessViewController: UIViewController, IChessViewController {

    @IBOutlet weak var boardView: BoardView!
    
    var chessEngine: IChessEngine!
    var game: ChessGame?
    
    @IBAction func newGame(_ sender: Any) {
        game = ChessGame(view: self.boardView.board)
        chessEngine = ChessEngine()
        
        game?.engine = chessEngine
        game?.newGame()
        chessEngine.presentation = game
        
        chessEngine.letComputersPlay()
    }
    @IBAction func clear(_ sender: Any) {
        chessEngine = nil
        game?.removeAll()
    }
    @IBAction func plusAction(_ sender: Any) {
        chessEngine.letComputersPlay()
    }
}

