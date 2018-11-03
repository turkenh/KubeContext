//
//  KubeContextTests.swift
//  KubeContextTests
//
//  Created by Turken, Hasan on 18.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import XCTest
@testable import KubeContext

class KubeContextBadFileTests: XCTestCase {
    var k8s: Kubernetes?
    var bundle: Bundle!
    
    override func setUp() {
        bundle = Bundle(for: type(of: self))
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoadNonExistingFile() {
        let url = URL(fileURLWithPath: "/non-existing-dir/non-existing-file")
        k8s = Kubernetes(configFile: url)
        XCTAssertNotNil(k8s)
        
        XCTAssertThrowsError(try k8s?.getConfig(), "Handle non existing file") { (error) in
            print(error)
            XCTAssertEqual((error as NSError).domain, "NSCocoaErrorDomain")
            // 260 -> The file <> couldn’t be opened because there is no such file.
            XCTAssertEqual((error as NSError).code, 260)
        }
    }
    
    func testLoadEmptyFile() {
        let url = bundle.url(forResource: "empty-file", withExtension: "yaml", subdirectory: "TestData")
        k8s = Kubernetes(configFile: url!)
        XCTAssertNotNil(k8s)
        
        XCTAssertThrowsError(try k8s?.getConfig(), "Handle empty file") { (error) in
            XCTAssertEqual((error as NSError).domain, "NSCocoaErrorDomain")
            // 4864 -> typeMismatch(Yams.Node.Mapping, Swift.DecodingError.Context(codingPath: [], debugDescription: "Expected to decode Mapping but found Node instead."
            XCTAssertEqual((error as NSError).code, 4864)
        }
    }
    
    func testLoadInvalidYaml() {
        let url = bundle.url(forResource: "invalid-yaml", withExtension: "yaml", subdirectory: "TestData")
        k8s = Kubernetes(configFile: url!)
        XCTAssertNotNil(k8s)
        
        XCTAssertThrowsError(try k8s?.getConfig(), "Handle invalid yaml file") { (error) in
            print(error)
            XCTAssertEqual((error as NSError).domain, "NSCocoaErrorDomain")
            // 4864 -> typeMismatch(Yams.Node.Mapping, Swift.DecodingError.Context(codingPath: [], debugDescription: "Expected to decode Mapping but found Node instead."
            XCTAssertEqual((error as NSError).code, 4864)
        }
    }

}
