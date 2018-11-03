//
//  Globals.swift
//  KubeContext
//
//  Created by Turken, Hasan on 20.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import Foundation
import os

let bundleID = Bundle.main.bundleIdentifier!
//let logger = OSLog(subsystem: bundleID, category: "kube")
var bookmarks = [URL: Data]()

var bookmarksFile = "Bookmarks.dict"
var uiTesting = false
var testFileToImport: URL?
var testFileAsConfig: URL?

var k8s: Kubernetes!
