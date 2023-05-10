//
//  MetaDisplay.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/9/23.
//

import UIKit

class MetaDisplay {
    private let inputDict: [String: [String: [String: String]]]

    init(inputDict: [String: [String: [String: String]]]) {
        self.inputDict = inputDict
    }

    func processText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "")

        let level1Attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]

        let level2Attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.cyan,
            .font: UIFont.boldSystemFont(ofSize: 15)
        ]

        let increaseAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.green,
            .font: UIFont.systemFont(ofSize: 13)
        ]

        let decreaseAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 13)
        ]

        let neutralAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13)
        ]

        for (category, updates) in inputDict {
               let categoryString = "\n\n\(category):\n\n"
               let categoryAttributedString = NSMutableAttributedString(string: categoryString, attributes: level1Attributes)
               attributedString.append(categoryAttributedString)
               
               for (updateTitle, updateContents) in updates {
                   let updateString = "\n  \(updateTitle):\n"
                   let updateAttributedString = NSMutableAttributedString(string: updateString, attributes: level2Attributes)
                   attributedString.append(updateAttributedString)
                   
                   for (updateKey, updateValue) in updateContents {
                       if updateValue.contains("⇒") {
                           let parts = updateValue.split(separator: "⇒").map { String($0.trimmingCharacters(in: .whitespaces)) }
                           if parts.count == 2 {
                               let beforeParts = parts[0].split(separator: " ").map { String($0) }
                               let afterParts = parts[1].split(separator: " ").map { String($0) }

                               let updateLine = "\n    \(updateKey): "
                               let updateLineAttributedString = NSMutableAttributedString(string: updateLine, attributes: neutralAttributes)
                               attributedString.append(updateLineAttributedString)

                               for i in 0..<beforeParts.count {
                                   if i < afterParts.count {
                                       let beforeStripped = beforeParts[i].trimmingCharacters(in: CharacterSet(charactersIn: "()%"))
                                       let afterStripped = afterParts[i].trimmingCharacters(in: CharacterSet(charactersIn: "()%"))
                                       
                                       if let beforeValue = Float(beforeStripped), let afterValue = Float(afterStripped) {
                                           let partAttributes = beforeValue < afterValue ? increaseAttributes : decreaseAttributes
                                           let partString = "\(beforeParts[i]) ⇒ \(afterParts[i]) "
                                           let partAttributedString = NSMutableAttributedString(string: partString, attributes: partAttributes)
                                           attributedString.append(partAttributedString)
                                       } else {
                                           let partString = "\(beforeParts[i]) ⇒ \(afterParts[i]) "
                                           let partAttributedString = NSMutableAttributedString(string: partString, attributes: neutralAttributes)
                                           attributedString.append(partAttributedString)
                                       }
                                   } else {
                                       let partString = "\(beforeParts[i]) "
                                       let partAttributedString = NSMutableAttributedString(string: partString, attributes: neutralAttributes)
                                       attributedString.append(partAttributedString)
                                   }
                               }
                               attributedString.append(NSMutableAttributedString(string: "\n"))
                           }
                       } else if updateValue.starts(with: "REMOVED") {
                           let updateLine = "\n    \(updateKey): "
                           let updateLineAttributedString = NSMutableAttributedString(string: updateLine, attributes: decreaseAttributes)
                           attributedString.append(updateLineAttributedString)
                           
                           let updateValueString = "\(updateValue)\n"
                           let updateValueAttributedString = NSMutableAttributedString(string: updateValueString, attributes: decreaseAttributes)
                           attributedString.append(updateValueAttributedString)
                       } else {
                           let updateLine = "\n    \(updateKey): \(updateValue)\n"
                           let updateLineAttributedString = NSMutableAttributedString(string: updateLine, attributes: neutralAttributes)
                           attributedString.append(updateLineAttributedString)
                       }
                   }
               }
           }

           return attributedString
    }
}






