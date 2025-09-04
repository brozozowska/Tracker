//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Сергей Розов on 30.08.2025.
//

import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        do {
            let data = try JSONEncoder().encode(days)
            return data
        } catch {
            print("❌ Не удалось закодировать [WeekDay]: \(error.localizedDescription)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let days = try JSONDecoder().decode([WeekDay].self, from: data)
            return days
        } catch {
            print("❌ Не удалось раскодировать [WeekDay]: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func register() {
        let transformer = DaysValueTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
