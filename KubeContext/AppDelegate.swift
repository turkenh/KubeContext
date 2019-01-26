//
//  AppDelegate.swift
//  KubeContext
//
//  Created by Turken, Hasan on 04.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import Cocoa
import Yams
import EonilFSEvents
import SwiftyStoreKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let menuManager = MenuManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            statusBarButton = button
            statusBarButton.image = NSImage(named:NSImage.Name("kubernetes-icon"))
            //button.imageHugsTitle = false
            //button.contentTintColor = NSColor.red
            //button.action = #selector(constructMenu(_:))
        }
        
        let menu = NSMenu()
        menu.delegate = menuManager
        statusItem.menu = menu
        
        if CommandLine.arguments.contains("--uitesting") {
            prepareForTesting()
        }
        
        k8s = Kubernetes()
        
        // For testing
        //UserDefaults.standard.set(false, forKey: keyPro)
        //UserDefaults.standard.removeObject(forKey: keyExistingUserPrePro)
        //UserDefaults.standard.set(existingUserPreProFalse, forKey: keyExistingUserPrePro)
        // End of For testing

        isPro = UserDefaults.standard.bool(forKey: keyPro)
        isExistingUserPrePro = UserDefaults.standard.integer(forKey: keyExistingUserPrePro)
        if isExistingUserPrePro == existingUserPreProUndefined {
            if k8s.kubeconfig == nil {
                isExistingUserPrePro = existingUserPreProFalse
                UserDefaults.standard.set(existingUserPreProFalse, forKey: keyExistingUserPrePro)
            }
            else {
                isExistingUserPrePro = existingUserPreProTrue
                UserDefaults.standard.set(existingUserPreProTrue, forKey: keyExistingUserPrePro)
            }
        }
        if isPro || isExistingUserPrePro == existingUserPreProTrue {
            maxNofContexts = unlimitedNofContexts
        }
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
    
    func prepareForTesting(){
        NSLog ("UI Testing Mode")
        bookmarksFile = "TestBookmarks.dict"
        uiTesting = true
        let fileManager = FileManager.default
        
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        url = url.appendingPathComponent(bookmarksFile)
        
        if fileManager.isReadableFile(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
        let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let tempDataUrl = documentDirectory!.appendingPathComponent("TempData")
        
        testFileAsConfig = tempDataUrl.appendingPathComponent("ui-test-config.yaml")
        testFileToImport = tempDataUrl.appendingPathComponent("file-to-import.yaml")
        
        UserDefaults.standard.set(true, forKey: keyPro)
    }
}
