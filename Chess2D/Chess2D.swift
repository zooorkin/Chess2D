//
//  ChessTypes.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 03/10/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

final class Chess2D {
    public enum PieceType {
        case pawn
        case king
        case rook
        case bishop
        case queen
        case knight
        
        public var name: String {
            switch self {
            case .bishop: return "Bishop"
            case .king: return "King"
            case .knight: return "Knight"
            case .pawn: return "Pawn"
            case .queen: return "Queen"
            case .rook: return "Rook"
            }
        }
        
        public func imageName(color: Color) -> String{
            switch color {
            case .white:
                switch self {
                case .bishop: return "w-bishop"
                case .king: return "w-king"
                case .knight: return "w-knight"
                case .pawn: return "w-pawn"
                case .queen: return "w-queen"
                case .rook: return "w-rook"
                }
            case .black:
                switch self {
                case .bishop: return "b-bishop"
                case .king: return "b-king"
                case .knight: return "b-knight"
                case .pawn: return "b-pawn"
                case .queen: return "b-queen"
                case .rook: return "b-rook"
                }
            }
        }
    }
    
    public enum Color{
        case white
        case black
    }
    
    public enum Difficulty {
        case easy
        case medium
        case hard
        case notSpecified
        
        public var name: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            case .notSpecified: return "Not specified"
            }
        }
    }
    
    public enum PlayerType{

        case human
        case computer
        
        var name: String {
            switch self {
            case .human: return "Human"
            case .computer: return "Computer"
            }
        }
    }

}




