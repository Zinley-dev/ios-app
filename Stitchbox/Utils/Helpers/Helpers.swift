//
//  File.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/30/22.
//

import Foundation

func isNotValidInput(Input: String, RegEx: String) -> Bool {
        //Declaring the rule of characters to be used. Applying rule to current state. Verifying the result.
        let test = NSPredicate(format: "SELF MATCHES %@", RegEx)
        let result = test.evaluate(with: Input)
        
        return !result
    }
