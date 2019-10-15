//
//  BoardView.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 26/09/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import UIKit

@IBDesignable
class BoardView: UIView {

    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var panelABCView: UIView!
    @IBOutlet weak var panelHGFView: UIView!
    @IBOutlet weak var panel123View: UIView!
    @IBOutlet weak var panel876View: UIView!
    
    var widthOfCell: CGFloat = 32
    var board: UIView {
        return boardView
    }
    
    override init(frame: CGRect) {
        panelViews = Panel()
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        panelViews = Panel()
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func loadFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "BoardView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first! as! UIView
    }
    
    override func layoutSubviews() {
        // FIXME: Нужно ли вызывать `super.layoutSubviews()`
        
        let width = boardView.frame.size.width / 8
        widthOfCell = width
        
        for i in 0..<8 {
            let label = panelViews.viewAbc[i]
            let x = CGFloat(i) * width
            let height = panelABCView.frame.size.height
            let rect = CGRect(x: x, y: 0, width: width, height: height)
            label.frame = rect
        }
        for i in 0..<8 {
            let label = panelViews.viewHgf[i]
            let x = CGFloat(i) * width
            let height = panelHGFView.frame.size.height
            let rect = CGRect(x: x, y: 0, width: width, height: height)
            label.frame = rect
        }
        for i in 0..<8 {
            let label = panelViews.view123[i]
            let y = CGFloat(i) * width
            let w = panel123View.frame.size.width
            let rect = CGRect(x: 0, y: y, width: w, height: width)
            label.frame = rect
        }
        for i in 0..<8 {
            let label = panelViews.view876[i]
            let y = CGFloat(i) * width
            let w = panel876View.frame.size.width
            let rect = CGRect(x: 0, y: y, width: w, height: width)
            label.frame = rect
        }
        for j in 0..<8 {
            for i in 0..<8 {
                let x = CGFloat(i) * width
                let y = CGFloat(j) * width
                let rect = CGRect(x: x, y: y, width: width, height: width)
                panelViews.cells[8*i + j].frame = rect
            }
        }
        print("layoutSubviews()")
    }

    struct Panel {
        var viewAbc: [UIView]
        var viewHgf: [UIView]
        var view123: [UIView]
        var view876: [UIView]
        var cells: [UIView]
        init() {
            self.viewAbc = []
            self.viewHgf = []
            self.view123 = []
            self.view876 = []
            self.cells   = []
        }
    }
    
    var panelViews: Panel
    
    func setupViews(){
        let xibView = loadFromXib()
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        panelABCView.backgroundColor = UIColor.clear
        for i in 0..<8{
            let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h"]
            let label = UILabel(frame: .zero)
            label.text = alphabet[i].uppercased()
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            panelABCView.addSubview(label)
            panelViews.viewAbc.append(label)
        }
        
        panelHGFView.backgroundColor = UIColor.clear
        for i in 0..<8{
            let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h"]
            let label = UILabel(frame: .zero)
            label.text = alphabet[i].uppercased()
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            let transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            label.transform = transform
            panelHGFView.addSubview(label)
            panelViews.viewHgf.append(label)
        }
        
        panel123View.backgroundColor = UIColor.clear
        for i in 0..<8{
            let alphabet = ["1", "2", "3", "4", "5", "6", "7", "8"]
            let label = UILabel(frame: .zero)
            label.text = alphabet[7 - i].uppercased()
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            panel123View.addSubview(label)
            panelViews.view123.append(label)
        }
        
        panel876View.backgroundColor = UIColor.clear
        for i in 0..<8{
            let alphabet = ["1", "2", "3", "4", "5", "6", "7", "8"]
            let label = UILabel(frame: .zero)
            label.text = alphabet[7 - i].uppercased()
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            let transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            label.transform = transform
            panel876View.addSubview(label)
            panelViews.view876.append(label)
        }
        
        for j in 0..<8 {
            for i in 0..<8 {
                let cell = UIView(frame: .zero)
                if (i + j) % 2 == 0{
                    let white: CGFloat = 232
                    cell.backgroundColor = UIColor(red: white/255, green: white/255, blue: white/255, alpha: 1)
                }else{
                    cell.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
                }
                boardView.addSubview(cell)
                panelViews.cells.append(cell)
            }
        }
        self.addSubview(xibView)
        
        let w = boardView.bounds.width
        let offset: CGFloat = 3
        let rect = CGRect(x: -offset, y: -offset, width: w + 2 * offset, height: w + 2 * offset)
        let viewBorderline = UIView(frame: rect)
        viewBorderline.backgroundColor = UIColor.clear
        viewBorderline.layer.borderColor = UIColor.darkGray.cgColor
        viewBorderline.layer.borderWidth = 2.0
        viewBorderline.isUserInteractionEnabled = false
        boardView.addSubview(viewBorderline)
        
    }
    
}
