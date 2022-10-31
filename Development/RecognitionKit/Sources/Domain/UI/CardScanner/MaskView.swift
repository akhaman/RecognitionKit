//
//  MaskView.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import UIKit

struct MaskStyle {
    let boundingRectangles: [CGRect]
    let rectCornerRadius: CGFloat
    let backgroundColor: UIColor
}

final class MaskView: UIView {
    private let style: MaskStyle

    // MARK: Init
    
    init(style: MaskStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initial Configuration
    
    private func setup() {
        isOpaque = false
        backgroundColor = style.backgroundColor
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor?.setFill()
        UIRectFill(rect)
        
        style.boundingRectangles.forEach { boundingRect in
            let path = UIBezierPath(roundedRect: boundingRect, cornerRadius: style.rectCornerRadius)
            let rectIntersection = rect.intersection(boundingRect)
            
            UIRectFill(rectIntersection)
            UIColor.clear.setFill()
            
            UIGraphicsGetCurrentContext()?.setBlendMode(.copy)
            path.fill()
        }
    }
}

extension MaskStyle {
    static var card: MaskStyle {
        MaskStyle(
            boundingRectangles: [],
            rectCornerRadius: 10,
            backgroundColor: .black.withAlphaComponent(0.6)
        )
    }
}
