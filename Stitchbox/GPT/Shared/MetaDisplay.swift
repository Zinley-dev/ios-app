//
//  MetaDisplay.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/9/23.
//

import UIKit

class MetaDisplay {
    
    private let inputDict: [String: [String: [String: String]]]

    init(jsonString: String) {
        self.inputDict = MetaDisplay.processInput(input: jsonString)
    }

    func processText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        
        let championAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        
        let categoryAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.cyan,
            .font: UIFont.boldSystemFont(ofSize: 15)
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13)
        ]
        
        print(inputDict)
        
        for (champion, categories) in inputDict {
            let championString = "\n\n\(champion):\n\n"
            let championAttributedString = NSMutableAttributedString(string: championString, attributes: championAttributes)
            attributedString.append(championAttributedString)
            
            for (category, details) in categories {
                let categoryString = "\n  \(category):\n"
                let categoryAttributedString = NSMutableAttributedString(string: categoryString, attributes: categoryAttributes)
                attributedString.append(categoryAttributedString)
                
                for (detailTitle, detailValue) in details {
                    let detailString = "\n    \(detailTitle): \(detailValue)\n"
                    let detailAttributedString = NSMutableAttributedString(string: detailString, attributes: valueAttributes)
                    attributedString.append(detailAttributedString)
                }
            }
        }
        
        return attributedString
    }
    
    
    static func processInput(input: String) -> [String: [String: [String: String]]] {
        let lines = input.components(separatedBy: "\n")
        
        var result = [String: [String: [String: String]]]()
        var currentSection = ""
        var currentSubSection = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty {
                continue
            }
            
            if trimmedLine.hasPrefix("*") {
                let updateTypeAndDetails = trimmedLine.components(separatedBy: ": ")
                
                if updateTypeAndDetails.count == 2 {
                    let updateType = updateTypeAndDetails[0].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "* "))
                    let updateDetails = updateTypeAndDetails[1]
                    
                    if var currentUpdates = result[currentSection] {
                        currentUpdates[updateType] = ["Details": updateDetails]
                        result[currentSection] = currentUpdates
                    }
                }
            } else if !trimmedLine.hasPrefix("*") {
                currentSection = trimmedLine
                result[currentSection] = [String: [String: String]]()
            }
        }
        
        return result
    }

}






