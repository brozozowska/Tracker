//
//  UIColorTransformer.swift
//  Tracker
//
//  Created by Сергей Розов on 30.08.2025.
//

import UIKit

@objc
final class UIColorTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
        } catch {
            print("Failed to decode UIColor: \(error)")
            return nil
        }
    }
    
    static func register() {
        let transformer = UIColorTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName(rawValue: String(describing: UIColorTransformer.self))
        )
    }
}
