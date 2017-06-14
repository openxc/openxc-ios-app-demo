//
//  VehicleCommandResponseTest.swift
//  openXCenabler
//
//  Created by Kanishka, Vedi (V.) on 10/06/17.
//  Copyright © 2017 Ford Motor Private Ltd. All rights reserved.
//

import XCTest
import openXCiOSFramework


class VehicleCommandResponseTest: XCTestCase {
    
    let cmd: VehicleCommandResponse = VehicleCommandResponse()
    
    // Static response in the format its actually received
    let verCmd: [String: Any] = ["message": "7.2.1-dev (emulator)", "status": true, "cmdResp": "version", "cmdType": "commandResponse"]
    let deviceIdCmd: [String: Any] = ["message": "AB:12:12:AB:12:AB", "status": true, "cmdResp": "device_id", "cmdType": "commandResponse"]
    let passthrCmd: [String: Any] = ["message": "", "status": true, "cmdResp": "passthrough", "cmdType": "commandResponse"]
    let afbypassCmd: [String: Any] = ["message": "", "status": true, "cmdResp": "af_bypass", "cmdType": "commandResponse"]
    let pformatCmd: [String: Any] = ["message": "", "status": true, "cmdResp": "payload_format", "cmdType": "commandResponse"]
    let platformCmd: [String: Any] = ["message": "CROSSCHASM_C5_BLE", "status": true, "cmdResp": "platform", "cmdType": "commandResponse"]
    let rtcCmd: [String: Any] = ["message": "", "status": true, "cmdResp": "rtc_configuration", "cmdType": "commandResponse"]
    let sdmountCmd: [String: Any] = ["message": "", "status": false, "cmdResp": "sd_mount_status", "cmdType": "commandResponse"]

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("********** test case name... ********** ", self.name!)

        var cmdStrToBeUsed: [String: Any] = verCmd
        
        if self.name?.lowercased().range(of: "version") != nil {
            cmdStrToBeUsed = verCmd
        } else if self.name?.lowercased().range(of: "device") != nil {
            cmdStrToBeUsed = deviceIdCmd
        } else if self.name?.lowercased().range(of: "passthrough") != nil {
            cmdStrToBeUsed = passthrCmd
        } else if self.name?.lowercased().range(of: "bypass") != nil {
            cmdStrToBeUsed = afbypassCmd
        } else if self.name?.lowercased().range(of: "payload") != nil {
            cmdStrToBeUsed = pformatCmd
        } else if self.name?.lowercased().range(of: "platform") != nil {
            cmdStrToBeUsed = platformCmd
        } else if self.name?.lowercased().range(of: "rtc") != nil {
            cmdStrToBeUsed = rtcCmd
        } else if self.name?.lowercased().range(of: "mount") != nil {
            cmdStrToBeUsed = sdmountCmd
        }

        cmd.message = cmdStrToBeUsed["message"] as! NSString
        cmd.status = cmdStrToBeUsed["status"]! as! Bool
        cmd.command_response = cmdStrToBeUsed["cmdResp"] as! NSString
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK: Tests for message in different commands
    func testVehicleCommandMessageNotNilForVersion() {
        XCTAssertFalse(cmd.message.isEqual(to: ""))
    }
    
    func testVehicleCommandMessageNotNilForPassthrough() {
        XCTAssertTrue(cmd.message.isEqual(to: ""))
    }
    
    func testVehicleCommandMessageNotNilForAfBypass() {
        XCTAssertTrue(cmd.message.isEqual(to: ""))
    }
   
    func testVehicleCommandMessageNotNilForPayloadFormat() {
        XCTAssertTrue(cmd.message.isEqual(to: ""))
    }
    
    func testVehicleCommandMessageNotNilForSDMount() {
        XCTAssertTrue(cmd.message.isEqual(to: ""))
    }
    
    //MARK: Tests for status in different commands
    func testCommandReturnsStatusForVersion() {
        XCTAssertTrue(cmd.status)
    }
    
    func testCommandReturnsStatusForSDMount() {
        XCTAssertFalse(cmd.status)
    }
    
    //MARK: Tests for type in different commands
    func testCommandTypeForVersion() {
        XCTAssertTrue(cmd.type.rawValue.isEqual(to: "commandResponse"))
    }

    //MARK: Tests for response in different commands
    func testCommandResponseForVersion() {
        XCTAssertTrue(cmd.command_response.isEqual(to: "version"))
    }

    func testCommandResponseForDeviceId() {
        XCTAssertTrue(cmd.command_response.isEqual(to: "device_id"))
    }
    
    func testCommandResponseForPassthrough() {
        XCTAssertTrue(cmd.command_response.isEqual(to: "passthrough"))
    }
    
    func testCommandResponseForAfBypass() {
        XCTAssertTrue(cmd.command_response.isEqual(to: "af_bypass"))
    }
    
    func testCommandResponseForPayloadFormat() {
        XCTAssertTrue(cmd.command_response.isEqual(to: "payload_format"))
    }
    
    func testCommandResponseForPlatform() {
        XCTAssertTrue(cmd.command_response.isEqual(to: "platform"))
    }
    
    func testCommandResponseForRTCConfig() {
        XCTAssertTrue(cmd.command_response.isEqual(to: "rtc_configuration"))
    }
    
    func testCommandResponseForSDMount() {
        XCTAssertTrue(cmd.command_response.isEqual(to: "sd_mount_status"))
    }

}
