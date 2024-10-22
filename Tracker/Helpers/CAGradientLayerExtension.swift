//
//  CAGradientLayerExtension.swift
//  Tracker
//
//  Created by Никита Козловский on 22.10.2024.
//

import UIKit

extension CAGradientLayer {
    var gradientLayer: CAGradientLayer {
        let gradient = CAGradientLayer()

        let color1 = UIColor(named: "ypSelection1")?.cgColor ?? UIColor().cgColor
        let color2 = UIColor(named: "ypSelection9")?.cgColor ?? UIColor().cgColor
        let color3 = UIColor(named: "ypSelection3")?.cgColor ?? UIColor().cgColor

        gradient.colors = [
           color1,
           color2,
           color3
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        return gradient
    }
}
