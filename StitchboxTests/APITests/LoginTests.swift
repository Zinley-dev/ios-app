//
//  LoginTests.swift
//  StitchboxTests
//
//  Created by Khanh Duy Nguyen on 11/11/22.
//

import XCTest
@testable import Stitchbox

class LoginTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNormalLogin() throws {
//        APIManager().normalLogin(email: "welcometrue1@gmail.com", password: "01662456611", completion: { result in
//                print(result)
//         })
        XCTAssertTrue(2 == 4)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
