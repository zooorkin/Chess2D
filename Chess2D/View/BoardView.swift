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
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func loadFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "BoardView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first! as! UIView
    }
    
    
    func setupViews(){
        let xibView = loadFromXib()
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let width = boardView.frame.size.width / 8
        widthOfCell = width

        panelABCView.backgroundColor = UIColor.clear
        for i in 0..<8{
            let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h"]
            let x = CGFloat(i) * width
            let height = panelABCView.frame.size.height
            let rect = CGRect(x: x, y: 0, width: width, height: height)
            let label = UILabel(frame: rect)
            label.text = alphabet[i].uppercased()
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            panelABCView.addSubview(label)
        }
        
        panelHGFView.backgroundColor = UIColor.clear
        for i in 0..<8{
            let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h"]
            let x = CGFloat(i) * width
            let height = panelHGFView.frame.size.height
            let rect = CGRect(x: x, y: 0, width: width, height: height)
            let label = UILabel(frame: rect)
            label.text = alphabet[i].uppercased()
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            let transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            label.transform = transform
            panelHGFView.addSubview(label)
        }
        panel123View.backgroundColor = UIColor.clear
        for i in 0..<8{
            let alphabet = ["1", "2", "3", "4", "5", "6", "7", "8"]
            let y = CGFloat(i) * width
            let w = panel123View.frame.size.width
            let rect = CGRect(x: 0, y: y, width: w, height: width)
            let label = UILabel(frame: rect)
            label.text = alphabet[7 - i].uppercased()
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            panel123View.addSubview(label)
        }
        panel876View.backgroundColor = UIColor.clear
        for i in 0..<8{
            let alphabet = ["1", "2", "3", "4", "5", "6", "7", "8"]
            let y = CGFloat(i) * width
            let w = panel876View.frame.size.width
            let rect = CGRect(x: 0, y: y, width: w, height: width)
            let label = UILabel(frame: rect)
            label.text = alphabet[7 - i].uppercased()
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            let transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            label.transform = transform
            panel876View.addSubview(label)
        }
        for j in 0..<8 {
            for i in 0..<8 {
                let x = CGFloat(i) * width
                let y = CGFloat(j) * width
                let rect = CGRect(x: x, y: y, width: width, height: width)
                let cell = UIView(frame: rect)
                if (i + j) % 2 == 0{
                    let white: CGFloat = 232
                    cell.backgroundColor = UIColor(red: white/255, green: white/255, blue: white/255, alpha: 1)
                }else{
                    cell.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
                }
                boardView.addSubview(cell)
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
