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
        k8s = Kubernetes()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoadNonExistingFile() {
        let url = URL(fileURLWithPath: "/non-existing-dir/non-existing-file")
        XCTAssertThrowsError(try k8s?.setKubeconfig(configFile: url))
    }
    
    func testLoadEmptyFile() {
        let url = bundle.url(forResource: "empty-file", withExtension: "yaml", subdirectory: "TestData")
        XCTAssertThrowsError(try k8s?.setKubeconfig(configFile: url))
    }
    
    func testLoadInvalidYaml() {
        let url = bundle.url(forResource: "invalid-yaml", withExtension: "yaml", subdirectory: "TestData")
        XCTAssertThrowsError(try k8s?.setKubeconfig(configFile: url))
    }

}
