//
//  MenuManager.swift
//  KubeContext
//
//  Created by Turken, Hasan on 12.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import Foundation
import Cocoa
import EonilFSEvents

class MenuManager: NSObject, NSMenuDelegate {
    var manageController: NSWindowController?
    
    override init() {
        super.init()
        let kubeconfigFileUrl = loadBookmarks()
        if kubeconfigFileUrl != nil {
            k8s = Kubernetes(configFile: kubeconfigFileUrl!)
            initWatcher((kubeconfigFileUrl?.path)!)
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        let kubeconfigFileUrl = loadBookmarks()
        if kubeconfigFileUrl == nil {
            ConstructInitMenu(menu: menu)
        } else {
            k8s = Kubernetes(configFile: kubeconfigFileUrl!)
            ConstructMainMenu(menu: menu)
        }
    }
    
    @objc func toggleState(_ sender: NSMenuItem) {
        let ctxMenu = sender.menu!.items
        for ctxM in ctxMenu {
            if ctxM != sender {
                ctxM.state = NSControl.StateValue.off
            }
        }
        if sender.state == NSControl.StateValue.off {
            sender.state = NSControl.StateValue.on
            do {
                try k8s.useContext(name: sender.title)
            } catch {
                NSLog ("Could not switch context: \(error)")
            }
        }
    }
    
    @objc func logClick(_ sender: NSMenuItem) {
        print("Clicked on " + sender.title)
    }
    
    @objc func openManagement(_ sender: NSMenuItem) {
        if (manageController == nil) {
            let storyboard = NSStoryboard(name: NSStoryboard.Name("Manage"), bundle: nil)
            manageController = storyboard.instantiateInitialController() as? NSWindowController
        }

        if (manageController != nil) {
            manageController!.showWindow(sender)
            manageController!.window?.orderFrontRegardless()
        }
    }

    @objc func importConfig(_ sender: NSMenuItem) {
        print("will import file...")
        if k8s == nil {
            alertUserWithWarning(message: "Not able to import config file, kubernetes not initialized!")
            return
        }
        var configToImportFileUrl: URL?
        if testFileToImport == nil {
            configToImportFileUrl = openFolderSelection()
        } else {
            configToImportFileUrl = testFileToImport
        }
        if configToImportFileUrl == nil {
            return
        }
        do {
            try k8s.importConfig(configToImportFileUrl: configToImportFileUrl!)
        } catch {
            alertUserWithWarning(message: "Not able to import config file \(error)")
        }
    }
    
    @objc func selectKubeconfig(_ sender: NSMenuItem) {
        do {
            try selectKubeconfigFile()
        } catch {
            alertUserWithWarning(message: "Could not parse selected kubeconfig file\n \(error)")
        }
    }
    
    func ConstructInitMenu(menu: NSMenu){
        menu.removeAllItems()
        let selectConfigMenuItem = NSMenuItem(title: "Select kubeconfig file", action:  #selector(selectKubeconfig(_:)), keyEquivalent: "c")
        selectConfigMenuItem.target = self
        menu.addItem(selectConfigMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    func ConstructMainMenu(menu: NSMenu){
        menu.removeAllItems()
        let centerParagraphStyle = NSMutableParagraphStyle.init()
        centerParagraphStyle.alignment = .center
        
        // Current Context Title
        let currentContextTitleItem = NSMenuItem(title: "", action: #selector(logClick(_:)), keyEquivalent: "")
        currentContextTitleItem.target=self
        let contextTitle = NSAttributedString.init(string: "Current Context", attributes: [NSAttributedString.Key.paragraphStyle: centerParagraphStyle, NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 14)])
        currentContextTitleItem.attributedTitle = contextTitle
        menu.addItem(currentContextTitleItem)
        
        // Current Context Text
        let switchContextSubmenu = NSMenu()
        
        var config: Config!
        do {
            config = try k8s.getConfig()
        } catch {
            NSLog("Could not parse config file \(error)")
            alertUserWithWarning(message: "Could not parse config file \n \(error)")
            return
        }
        
        
        let currentContext = config.CurrentContext
        let ctxs = config.Contexts
        for ctx in ctxs {
            let ctxMenuItem = NSMenuItem(title: ctx.Name, action: #selector(toggleState(_:)), keyEquivalent: "")
            ctxMenuItem.target = self
            if ctx.Name == currentContext {
                ctxMenuItem.state = .on
            }
            switchContextSubmenu.addItem(ctxMenuItem)
        }
        
        if switchContextSubmenu.items.count < 1 {
            let noCtxMenuItem = NSMenuItem(title: "No more contexts", action: nil, keyEquivalent: "")
            switchContextSubmenu.addItem(noCtxMenuItem)
        }
        
        let currentContextTextItem = NSMenuItem(title: "", action: #selector(logClick(_:)), keyEquivalent: "")
        currentContextTextItem.target = self
        let currentContextText = NSAttributedString.init(string: currentContext.wrap(limit: 32), attributes: [NSAttributedString.Key.paragraphStyle: centerParagraphStyle])
        currentContextTextItem.attributedTitle = currentContextText
        menu.addItem(currentContextTextItem)
        
        // Seperator
        menu.addItem(NSMenuItem.separator())
        
        // Switch Context
        let switchContextMenuItem = NSMenuItem(title: "Switch Context", action: nil, keyEquivalent: "c")
        switchContextMenuItem.target = self
        menu.addItem(switchContextMenuItem)
        // Switch Context Submenu
        menu.setSubmenu(switchContextSubmenu, for: switchContextMenuItem)
        
        // Import Kubeconfig file
        let importKubeconfigMenuItem = NSMenuItem(title: "Import Kubeconfig File", action: #selector(importConfig(_:)), keyEquivalent: "i")
        importKubeconfigMenuItem.target = self
        menu.addItem(importKubeconfigMenuItem)
        
        let manageContextMenuItem = NSMenuItem(title: "Manage Contexts", action: #selector(openManagement(_:)), keyEquivalent: "m")
        manageContextMenuItem.target = self
        menu.addItem(manageContextMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    func alertUserWithWarning(message: String) {
        let alert = NSAlert()
        alert.icon = NSImage.init(named: NSImage.cautionName)
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}


