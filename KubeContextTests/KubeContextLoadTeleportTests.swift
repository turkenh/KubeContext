//
//  KubeContextMiniKube.swift
//  KubeContextTests
//
//  Created by Andy Steinmann on 9/4/21.
//  Copyright © 2021 Turken, Hasan. All rights reserved.
//

import XCTest
@testable import KubeContext

class KubeContextLoadTeleportTests: XCTestCase {
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
    
    func testLoadTeleportFile() {
        let url = bundle.url(forResource: "teleport", withExtension: "yaml", subdirectory: "TestData")
        XCTAssertNoThrow(try k8s?.setKubeconfig(configFile: url));
    }
}
