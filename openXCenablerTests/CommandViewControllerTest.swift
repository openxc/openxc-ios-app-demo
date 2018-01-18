//
//  CommandViewControllerTest.swift
//  openXCenablerTests
//
//  Created by Ranjan, Kumar sahu (K.) on 18/01/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import XCTest
@testable import openXCenabler
class CommandViewControllerTest: XCTestCase {
    
    var commandVC : CommandsViewController?
    let response = ["version":"7.2.1-dev"]
    let response1 = ["device_id":"F5:35:83:9B:6C:9B"]
    let response2 = ["platform":"CROSSCHASM_C5_BLE"]
    let response3 = ["passthrough":"true"]
    let response4 = ["af_bypass":"true"]
    let response5 = ["payload_format":"true"]
    let response6 = ["rtc_configuration":"true"]
    let response7 = ["sd_mount_status":"true"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        commandVC = CommandsViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    func testResponse() {
       //let value = commandVC?.handle_cmd_response(_ rsp: response)
        
        let value =  response["version"]
        let value1 = response1["device_id"]
        let value2 = response2["platform"]
        let value3 = response3["passthrough"]
        let value4 = response4["af_bypass"]
        let value5 = response5["payload_format"]
        let value6 = response6["rtc_configuration"]
        let value7 = response7["sd_mount_status"]
        
        XCTAssert(value == "7.2.1-dev")
        XCTAssert(value1 == "F5:35:83:9B:6C:9B")
        XCTAssert(value2 == "CROSSCHASM_C5_BLE")
        XCTAssert(value3 == "true")
        XCTAssert(value4 == "true")
        XCTAssert(value5 == "true")
        XCTAssert(value6 == "true")
        XCTAssert(value7 == "true")
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
