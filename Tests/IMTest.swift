//
//  IMTest.swift
//  IMServer
//
//  Created by Yiqiang Zeng on 2019/2/23.
//

import XCTest

class IMTest: XCTestCase {

    //MARK: - 测试随机数生成
    func testRandomNumber() {
        for _ in 0..<10 {
            print(Util.randomNumber(min: 10, max: 20))
        }
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
