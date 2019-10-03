//
//  ChessCoordinator.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 03/10/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import UIKit

class ChessCoordinator {
    
    func chessView() -> ChessViewController {
        let model = ChessModel()
        let presenter = ChessPresenter(model: model)
        let view = ChessViewController(presenter: presenter)
        
        model.delegate = presenter
        presenter.delegate = view
        return view
    }
    
    
}
