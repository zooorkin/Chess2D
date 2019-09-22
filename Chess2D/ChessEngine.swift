//
//  ChessEngine.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 21/09/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import Foundation
import SwiftChess

protocol IChessEngine: class {
    var blackType: PlayerType { get }
    var whiteType: PlayerType { get }
    var presentation: ChessGame? { get set }
    func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int))
    func letComputersPlay()
}

class ChessEngine: IChessEngine, GameDelegate {
    
    var player1: Player
    var player2: Player
    var game: Game
    public var presentation: ChessGame?
    
    init() {
                player1 = Human(color: .white)
        //       player2 = Human(color: .black)
        //player1 = AIPlayer(color: .white, configuration: .init(difficulty: .easy))
        player2 = AIPlayer(color: .black, configuration: .init(difficulty: .medium))
        game = Game(firstPlayer: player1, secondPlayer: player2)
        game.delegate = self
    }
    
    private var blockComputerAsyncNextStep = false
    public func letComputersPlay(){
        if !blockComputerAsyncNextStep {
            if let player =  game.currentPlayer as? AIPlayer {
                player.makeMoveAsync()
                blockComputerAsyncNextStep = true
            }
        }
    }
    
    public var blackType: PlayerType {
        if game.blackPlayer is Human {
            return .human
        } else {
            return .computer
        }
    }
    public var whiteType: PlayerType {
        if game.whitePlayer is Human {
            return .human
        } else {
            return .computer
        }
    }
    
    public func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int)){
        if let player = game.currentPlayer as? Human {
            let currentLocation = BoardLocation(x: from.x, y: from.y)
            guard player.occupiesSquare(at: currentLocation) else{
                print("Игроку эта фигура недоступна")
                return
            }
            let newLocation = BoardLocation(x: to.x, y: to.y)
            let piece = game.board.getPiece(at: currentLocation)!
            var possibleLocations = game.board.possibleMoveLocationsForPiece(atLocation: currentLocation)
            switch player.color! {
            case .white:
                if game.board.canColorCastle(color: .white, side: .kingSide){
                    possibleLocations += [BoardLocation(gridPosition: .g1)]
                }
                if game.board.canColorCastle(color: .white, side: .queenSide){
                    possibleLocations += [BoardLocation(gridPosition: .c1)]
                }
                break
            case .black:
                if game.board.canColorCastle(color: .black, side: .kingSide){
                    possibleLocations += [BoardLocation(gridPosition: .g8)]
                }
                if game.board.canColorCastle(color: .black, side: .queenSide){
                    possibleLocations += [BoardLocation(gridPosition: .c8)]
                }
                break
            }
            
            guard possibleLocations.contains(newLocation) else {
                print("Not possible movement")
                presentation?.movePiece(tag: piece.tag, to: from, animating: true)
                return
            }
            switch newLocation.gridPosition {
            case .g1, .g8:
                player.performCastleMove(side: .kingSide)
                break;
            case .c1, .c8:
                player.performCastleMove(side: .queenSide)
                break;
            default:
                do {
                    try player.movePiece(from: currentLocation,
                                         to: newLocation)
                }catch {
                    print("This code wil never be EXECUTED! (?)")
                    // Запустился
                }
            }
        }
        if let player =  game.currentPlayer as? AIPlayer {
            player.makeMoveAsync()
        }
    }
    
    func gameWillBeginUpdates(game: Game) {
        print("--gameWillBeginUpdates")
    }
    
    func gameDidAddPiece(game: Game) {
        print("--gameDidAddPiece")
    }
    
    func gameDidEndUpdates(game: Game) {
        print("--gameDidEndUpdates")
    }
    
    func promotedTypeForPawn(location: BoardLocation, player: Human, possiblePromotions: [Piece.PieceType], callback: @escaping (Piece.PieceType) -> Void) {
        print("A pawn was promoted!")
    }
    
    func gameDidMovePiece(game: Game, piece: Piece, toLocation: BoardLocation) {
        if game.currentPlayer is AIPlayer {
            presentation?.movePiece(tag: piece.tag, to: (x: toLocation.x, y: toLocation.y), animating: true)
        }else{
            presentation?.movePiece(tag: piece.tag, to: (x: toLocation.x, y: toLocation.y), animating: countOfMovements > 0)
        }
        countOfMovements += 1
        print("to \(toLocation.gridPosition)")
    }
    
    func gameDidRemovePiece(game: Game, piece: Piece, location: BoardLocation) {
        presentation?.removePiece(tag: piece.tag)
        print("From \(location) ", terminator: "")
    }
    
    func gameDidTransformPiece(game: Game, piece: Piece, location: BoardLocation) {
        print("A pawn was promoted!")
    }
    
    func gameWonByPlayer(game: Game, player: Player) {
        print("Checkmate!")
        //ShowAlert("Checkmate!")
    }
    
    func gameEndedInStaleMate(game: Game) {
        print("Stalemate!")
        //ShowAlert("Stalemate!")
    }
    
    private var countOfMovements = 0
    
    func gameDidChangeCurrentPlayer(game: Game) {
        countOfMovements = 0
        blockComputerAsyncNextStep = false
        switch game.currentPlayer.color! {
        case Color.black:
            presentation?.currentPlayerIs(color: .black)
            print("Ходят чёрные")
        case Color.white:
            presentation?.currentPlayerIs(color: .white)
            print("Ходят белые")
        }
        // Make another move
    }
    
}
