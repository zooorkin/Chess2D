//
//  piece.swift
//  Chess
//
//  Created by Андрей Зорькин on 22.07.17.
//  Copyright © 2017 Андрей Зорькин. All rights reserved.
//

import UIKit

protocol IChessPresenter {
    var delegate: IChessPresenterDelegate? {get set}
    func newGame(whitePlayerType: Chess2D.PlayerType, blackPlayerType: Chess2D.PlayerType, difficulty: Chess2D.Difficulty)
    func endGame()
    func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int))
    func freezeOthers(excluding: Int)
    func freezeFor(color: Chess2D.Color)
}

protocol IChessPresenterDelegate: class {
    func presenterDidAddPiece(at point: (x: Int, y: Int), type: Chess2D.PieceType, color: Chess2D.Color)
    func presenterDidFreezeAll()
    func presenterDidFreezeFor(color: Chess2D.Color)
    func presenterDidFreezeOthers(excluding: Int)
    func presenterDidEndGame()
    func presenterDidMovePiece(tag: Int, to: (x: Int, y: Int), animating: Bool)
    func presenterDidRemovePiece(tag: Int)
    func presenterGameWonByPlayer(color: Chess2D.Color)
    func presenterGameEndedInStaleMate()
    func presenterPromotedTypeForPawn(callback: @escaping (Chess2D.PieceType) -> Void)
    func presenterDidChangeTypeOfPiece(tag: Int, newType: Chess2D.PieceType)
}

class ChessPresenter: IChessPresenter{
    
    
    public weak var delegate: IChessPresenterDelegate?
    
    public var model: IChessModel

    var whitePlayerType: Chess2D.PlayerType!
    var blackPlayerType: Chess2D.PlayerType!
    
    init(model: IChessModel) {
        self.model = model
        self.model.delegate = self
    }
    
    private var started = false
    
    public func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int)){
        model.makeMove(from: (x: from.x - 1, y: from.y - 1), to: (x: to.x - 1, y: to.y - 1))
    }
    
    public func freezeOthers(excluding: Int){
        delegate?.presenterDidFreezeOthers(excluding: excluding)
    }
    
    public func addPiece(at point: (x: Int, y: Int), type: Chess2D.PieceType, color: Chess2D.Color){
       delegate?.presenterDidAddPiece(at: point, type: type, color: color)
    }
    
    public func freezeAll(){
        delegate?.presenterDidFreezeAll()
    }
    
    public func freezeFor(color: Chess2D.Color){
        delegate?.presenterDidFreezeFor(color: color)
    }
    
    public func newGame(whitePlayerType: Chess2D.PlayerType = .human, blackPlayerType: Chess2D.PlayerType = .computer, difficulty: Chess2D.Difficulty = .notSpecified){
        model.newGame(player1: whitePlayerType, player2: blackPlayerType, difficulty: difficulty)
        if started == false{
            self.whitePlayerType = model.whiteType
            self.blackPlayerType = model.blackType
            let FiguresPosition: [Chess2D.PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
            for (i, FigureType) in FiguresPosition.enumerated(){
                delegate?.presenterDidAddPiece(at: (x: i + 1, y: 1), type: FigureType, color: .white)
            }
            for i in 1...8{
                delegate?.presenterDidAddPiece(at: (x: i, y: 2), type: .pawn, color: .white)
            }
            for (i, FigureType) in FiguresPosition.enumerated(){
                delegate?.presenterDidAddPiece(at: (x: i + 1, y: 8), type: FigureType, color: .black)
            }
            for i in 1...8{
                delegate?.presenterDidAddPiece(at: (x: i, y: 7), type: .pawn, color: .black)
            }
            setCurrentPlayerColor(color: .white)
            started = true
        }
    }
    
    public func endGame(){
        started = false
        model.endGame()
        delegate?.presenterDidEndGame()
    }
    
    private func setCurrentPlayerColor(color: Chess2D.Color){
        switch color {
        case .black:
            if blackPlayerType == .computer {
                freezeAll()
            }else{
                freezeFor(color: .white)
            }
        case .white:
            if whitePlayerType == .computer {
                freezeAll()
            }else{
                freezeFor(color: .black)
            }
        }
    }
    
}


extension ChessPresenter: IChessModelDelegate {
    func chessModelDidMovePiece(tag: Int, to: (x: Int, y: Int), animating: Bool) {
        delegate?.presenterDidMovePiece(tag: tag, to: to, animating: animating)
    }
    
    func chessModelDidRemovePiece(tag: Int) {
        delegate?.presenterDidRemovePiece(tag: tag)
    }
    
    func chessModelDidChangePlayer(currentPlayeColor: Chess2D.Color) {
        setCurrentPlayerColor(color: currentPlayeColor)
    }
    
    func chessModelGameWonByPlayer(color: Chess2D.Color) {
        delegate?.presenterGameWonByPlayer(color: color)
    }
    
    func chessModelGameEndedInStaleMate() {
        delegate?.presenterGameEndedInStaleMate()
    }
    
    func chessModelPromotedTypeForPawn(callback: @escaping (Chess2D.PieceType) -> Void) {
        delegate?.presenterPromotedTypeForPawn(callback: callback)
    }
    
    func chessModelDidChangeTypeOfPiece(tag: Int, newType: Chess2D.PieceType) {
        delegate?.presenterDidChangeTypeOfPiece(tag: tag, newType: newType)
    }
}

