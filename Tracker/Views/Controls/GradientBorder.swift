//
//  GradientBorder.swift
//  Tracker
//
//  Created by Сергей Розов on 04.10.2025.
//

import UIKit

enum GradientBorder {
    static func apply(
        to view: UIView,
        cornerRadius: CGFloat = 16,
        borderWidth: CGFloat = 1
    ) {
        if let existingGradient = view.layer.sublayers?.first(where: { $0.name == "gradientBorder" }) as? CAGradientLayer {
            existingGradient.frame = view.bounds
            if let shape = existingGradient.mask as? CAShapeLayer {
                shape.path = UIBezierPath(
                    roundedRect: view.bounds.insetBy(dx: borderWidth, dy: borderWidth),
                    cornerRadius: cornerRadius - borderWidth
                ).cgPath
            }
            return
        }
        
        let gradient = CAGradientLayer()
        gradient.name = "gradientBorder"
        gradient.colors = [
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        
        let shape = CAShapeLayer()
        shape.lineWidth = borderWidth * 2
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        shape.path = UIBezierPath(
            roundedRect: view.bounds.insetBy(dx: borderWidth, dy: borderWidth),
            cornerRadius: cornerRadius - borderWidth
        ).cgPath
        
        gradient.mask = shape
        view.layer.addSublayer(gradient)
        gradient.frame = view.bounds
    }
    
    static func remove(from view: UIView) {
        view.layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })
    }
}
