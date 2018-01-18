//
//  StatusViewControllerTest.swift
//  openXCenablerTests
//
//  Created by Ranjan, Kumar sahu (K.) on 18/01/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import XCTest
@testable import openXCenabler

class StatusViewControllerTest: XCTestCase {
    
    var statusVC : StatusViewController?
    let response = ["version":"7.2.1-dev"]
    let response1 = ["device_id":"F5:35:83:9B:6C:9B"]
    let response2 = ["platform":"CROSSCHASM_C5_BLE"]
    
    var Ip : String = "0.0.0.0:50001"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        statusVC = StatusViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testResponse() {
        
        //let value = commandVC?.handle_cmd_response(_ rsp: response)
        
        let value = response["version"]
        let value1 = response1["device_id"]
        let value2 = response2["platform"]
        
        XCTAssert(value == "7.2.1-dev")
        XCTAssert(value1 == "F5:35:83:9B:6C:9B")
        XCTAssert(value2 == "CROSSCHASM_C5_BLE")
       
    }
    func testManagerResponse(){
        
    }
    func testNetworkIpAdress(){
        if (Ip != ""){
            
            var myStringArr = Ip.components(separatedBy: ":")
            let ip = myStringArr[0] //"0.0.0.0"
            let port = Int(myStringArr[1]) //50001
            
            XCTAssert(ip == "0.0.0.0")
            XCTAssert(port == 50001)
        }
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
