//
//  IntTransformable.swift
//  Tracker
//
//  Created by Юрий Гриневич on 17.09.2024.
//

import Foundation

//@objc(IntTransformable) final class IntTransformer: ValueTransformer {
//    override class func transformedValueClass() -> AnyClass { NSData.self }
//    override class func allowsReverseTransformation() -> Bool { true }
//    
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let schedule = value as? [Int] else { return nil }
//        return try? JSONEncoder().encode(schedule)
//    }
//
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let schedule = value as? Int else { return nil }
//        return try? JSONDecoder().decode([Int].self, from: schedule as Int)
//    }
//
//    static func register() {
//            ValueTransformer.setValueTransformer(
//                IntTransformer(),
//                forName: NSValueTransformerName(rawValue: String(describing: IntTransformer.self))
//            )
//        }
//}
//
//extension NSValueTransformerName {
//    static let IntTransformerName = NSValueTransformerName(rawValue: String(describing: IntTransformer.self))
//}
