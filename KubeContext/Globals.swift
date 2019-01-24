//
//  Globals.swift
//  KubeContext
//
//  Created by Turken, Hasan on 20.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import Foundation
import os
import Cocoa

let bundleID = Bundle.main.bundleIdentifier!
let proProductId = bundleID + ".pro"

let keyPro = "pro"
let keyExistingUserPrePro = "pre-pro-existing-user"
let keyShowContextOnMenu = "show-context-name"
let keyIconColorPrefix = "icon-color-"
//let logger = OSLog(subsystem: bundleID, category: "kube")
var uiTesting = false
var testFileToImport: URL?
var testFileAsConfig: URL?

var k8s: Kubernetes!
var statusBarButton: NSStatusBarButton!

var proProductPriceString = ""

let maxContextsForFree = 5

var maxNofContexts = maxContextsForFree

let existingUserPreProUndefined = 0
let existingUserPreProFalse = 1
let existingUserPreProTrue = 2

var isExistingUserPrePro = existingUserPreProUndefined
var isPro = false


