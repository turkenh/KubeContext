//
//  ManageViewController.swift
//  KubeContext
//
//  Created by Turken, Hasan on 13.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import Cocoa
import SwiftyStoreKit

class ManageViewController: NSViewController, NSWindowDelegate {
    let fileManager = FileManager.default
    var contexts: [ContextElement]?
    var activeRowIndex = 0
    var config: Config!
    var importButtonAction="import"
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var clusterPopUpButton: NSPopUpButton!
    @IBOutlet weak var userPopUpButton: NSPopUpButton!
    @IBOutlet weak var namespaceTextField: NSTextField!
    @IBOutlet weak var serverLabel: NSTextField!
    
    @IBOutlet weak var applyButton: NSButton!
    @IBOutlet weak var revertButton: NSButton!
    @IBOutlet weak var importRestoreButton: NSButton!
    
    @IBOutlet weak var kubeConfigFileLabel: NSTextField!
    @IBOutlet weak var showContextCheckbox: NSButton!
   
    @IBOutlet weak var contextLockButton: NSButton!
    
    
    private var dragDropType = NSPasteboard.PasteboardType(rawValue: "private.table-row")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        importButtonAction="import"
        importRestoreButton.title = "Import Kubeconfig"
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        nameTextField.delegate = self
        namespaceTextField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.action = #selector(tableViewClick(_:))
        tableView.selectionHighlightStyle = .sourceList
        tableView.registerForDraggedTypes([dragDropType])
        
        let isPro = UserDefaults.standard.bool(forKey: keyPro)
        if isPro {
            unlock()
        }
        let shouldShowContextName = UserDefaults.standard.bool(forKey: keyShowContextOnMenu)
        
        if shouldShowContextName {
            showContextCheckbox.state = .on
        } else {
            showContextCheckbox.state = .off
        }
    }
    
    func unlock() {
        self.contextLockButton.isHidden = true
        self.showContextCheckbox.isEnabled = true
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if applyButton.isEnabled {
            return confirmExit()
        }
        return true
    }
    
    override func flagsChanged(with event: NSEvent) {
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.option]:
            importButtonAction="restore"
            importRestoreButton.title = "Restore Original"
            importRestoreButton.isHidden = false
        default:
            importRestoreButton.isHidden = true
            importButtonAction="import"
            importRestoreButton.title = "Import Kubeconfig"
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.parent?.view.window?.title = self.title!
        self.view.window?.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        freshReload(true)
    }
    
    func freshReload(_ setActiveToCurrent:Bool = false) {
        fetchConfig()
        if setActiveToCurrent {
            for (i, ctx) in config.Contexts.enumerated() {
                if ctx.Name == config.CurrentContext {
                    activeRowIndex = i
                }
            }
        }
        refreshTable()
    }
    
    func refreshTable() {
        loadConfig()
        tableView.reloadData()
        tableView.selectRowIndexes(NSIndexSet(index: activeRowIndex) as IndexSet, byExtendingSelection: false)
    }
    
    func fetchConfig() {
        do {
            config = try k8s.getConfig()
        } catch {
            NSLog("Could not fetch config: \(error)")
            return
        }
        
        kubeConfigFileLabel.stringValue = k8s.getConfigFilePath()
    }
    
    func loadConfig(){
        applyButton.isEnabled = false
        revertButton.isEnabled = false
        
        clusterPopUpButton.removeAllItems()
        userPopUpButton.removeAllItems()
        
        guard let ctxs = config?.Contexts else {
            NSLog("Could not get contexts from config")
            return
        }
        contexts = ctxs
        
        guard let clusters = config?.Clusters else {
            NSLog("Could not get clusters from config")
            return
        }
        for c in clusters {
            clusterPopUpButton.addItem(withTitle: c.Name)
        }
        
        guard let users = config?.AuthInfos else {
            NSLog("Could not get users from config")
            return
        }
        for u in users {
            userPopUpButton.addItem(withTitle: u.Name)
        }
        loadActiveContext()
    }
    
    @objc func tableViewClick(_ sender:AnyObject) {
        // 1
        activeRowIndex = tableView.selectedRow
        loadActiveContext()
    }
    
    func loadActiveContext() {
        guard let nofContexts = contexts?.count else {
            NSLog("Could not get nof contexts")
            return
        }
        if nofContexts < 1 {
            NSLog("No context available to load")
            return
        }
        
        if activeRowIndex < 0 || activeRowIndex > (nofContexts - 1) {
            activeRowIndex = 0
        }
        guard let item = contexts?[activeRowIndex] else {
            NSLog("Could not get context item to load")
            return
        }
        nameTextField.stringValue = item.Name
        
        clusterPopUpButton.selectItem(withTitle: item.Context.Cluster)
        serverLabel.stringValue = ""
        if let clusters = config?.Clusters {
            for c in clusters {
                if c.Name == item.Context.Cluster {
                    serverLabel.stringValue = "Server: " + c.Cluster.Server
                }
            }
        }
        
        userPopUpButton.selectItem(withTitle: item.Context.AuthInfo)
        
        if let namespace = item.Context.Namespace {
            namespaceTextField.stringValue = namespace
        } else {
            namespaceTextField.stringValue = ""
            namespaceTextField.placeholderString = "default"
        }
    }
    
    func confirmExit() -> Bool {
        let alert = NSAlert()
        alert.icon = NSImage.init(named: NSImage.cautionName)
        alert.messageText = "There are changes that have not been applied. Would you like to apply them?"
        alert.addButton(withTitle: "Apply")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Don't Apply")
        let resp = alert.runModal()
        if (resp == NSApplication.ModalResponse.alertFirstButtonReturn){
            self.applyClicked(self)
            return true
        } else if(resp==NSApplication.ModalResponse.alertSecondButtonReturn){
            return false
        } else if(resp==NSApplication.ModalResponse.alertThirdButtonReturn){
            return true
        }
        return true
    }
    
    func alertUserWithWarning(message: String) {
        let alert = NSAlert()
        alert.icon = NSImage.init(named: NSImage.cautionName)
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!)
    }
    
    @IBAction func applyClicked(_ sender: Any) {
        if config == nil {
            NSLog("Error: Apply clicked but config not loaded")
            return
        }
        
        if nameTextField.stringValue == "" {
            alertUserWithWarning(message: "Context name cannot be empty!")
            return
        }
        
        var latestConfig: Config!
        do {
            latestConfig = try k8s.getConfig()
        } catch {
            NSLog("Not able to get latest config \(error))")
        }
        
        if config.Contexts[activeRowIndex].Name == latestConfig.CurrentContext {
            config.CurrentContext = nameTextField.stringValue
        }
        
        config.Contexts[activeRowIndex].Name = nameTextField.stringValue
        config.Contexts[activeRowIndex].Context.Cluster = clusterPopUpButton.titleOfSelectedItem!
        config.Contexts[activeRowIndex].Context.AuthInfo = userPopUpButton.titleOfSelectedItem!
        if namespaceTextField.stringValue != "" {
            config.Contexts[activeRowIndex].Context.Namespace = namespaceTextField.stringValue
        }
        
        do {
            try k8s.saveConfig(config: config!)
        } catch {
            NSLog("Not able to save config \(error))")
        }
        freshReload()
        
        applyButton.isEnabled = false
        revertButton.isEnabled = false
    }
    
    @IBAction func revertClicked(_ sender: Any) {
        freshReload()
        
        applyButton.isEnabled = false
        revertButton.isEnabled = false
    }
    
    @IBAction func clusterPopButtonAction(_ sender: Any) {
        applyButton.isEnabled = true
        revertButton.isEnabled = true
        
        guard let btn = sender as? NSPopUpButton else {
            return
        }
        if let clusters = config?.Clusters {
            for c in clusters {
                if c.Name == btn.title {
                    serverLabel.stringValue = "Server: " + c.Cluster.Server
                }
            }
        }
    }
    
    @IBAction func userPopupButtonAction(_ sender: Any) {
        applyButton.isEnabled = true
        revertButton.isEnabled = true
    }
    
    @IBAction func bottomControlAction(_ sender: NSSegmentedControl) {
        
        switch sender.selectedSegment {
        case 0:
            importContext()
        case 1:
            removeCurrentContext()
        case 2:
            addNewContext()
        case 3:
            exportSelectedContext()
        default:
            NSLog("Unknown segment in bottom controls")
        }
        
    }
    
    func exportSelectedContext() {
        var toExport = Config()
    
        let ctx = config.Contexts[activeRowIndex]
        let clusters = config.Clusters
        
        var cluster: ClusterElement!
        var user: AuthInfoElement!
        
        for c in clusters {
            if ctx.Context.Cluster == c.Name {
                cluster = c
                break
            }
        }
        
        let users = config.AuthInfos
        for u in users {
            if ctx.Context.AuthInfo == u.Name {
                user = u
                break
            }
        }
        
        toExport.Contexts.append(config.Contexts[activeRowIndex])
        toExport.CurrentContext = config.Contexts[activeRowIndex].Name
        toExport.Clusters.append(cluster)
        toExport.AuthInfos.append(user)
        
        let configToExportFileUrl = saveFolderSelection()
        if configToExportFileUrl == nil {
            NSLog("Could not export selected context\n Failed to get filepath! (User cancelled?)")
            return
        }
        do {
            try saveConfigToFile(config: toExport, file: configToExportFileUrl)
        } catch {
            alertUserWithWarning(message: "Could not export selected context\n \(error)")
        }
        
        let alert = NSAlert()
        alert.icon = NSImage.init(named: NSImage.infoName)
        alert.messageText = "Context \"" + config.Contexts[activeRowIndex].Name + "\" exported successfully!"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func addNewContext() {
        NSLog("Adding new context")
        var newContext = config?.Contexts[activeRowIndex]
        let oldName = newContext?.Name
        newContext?.Name = "Copy-of-" + oldName!
        
        config?.Contexts.append(newContext!)
        activeRowIndex = (config?.Contexts.count)! - 1
        
        refreshTable()
        
        applyButton.isEnabled = true
        revertButton.isEnabled = true
    }
    
    func removeUnusedClustersAndUsers(){
        var usedAuthInfos: [AuthInfoElement] = []
        var usedClusters: [ClusterElement] = []
        
        let contexts = config.Contexts
        let clusters = config.Clusters
        for c in clusters {
            for ctx in contexts {
                if ctx.Context.Cluster == c.Name {
                    usedClusters.append(c)
                    break
                }
            }
        }
        
        let users = config.AuthInfos
        for u in users {
            for ctx in contexts {
                if ctx.Context.AuthInfo == u.Name {
                    usedAuthInfos.append(u)
                    break
                }
            }
        }
        
        config.Clusters = usedClusters
        config.AuthInfos = usedAuthInfos
    }
    
    func removeCurrentContext() {
        guard let nofContexts = contexts?.count else {
            NSLog("Could not get nof contexts")
            return
        }
        if nofContexts < 2 {
            alertUserWithWarning(message: "Cannot remove all contexts, there has to be at least 1!")
            return
        }
        
        NSLog("Removing current context")
        let contextToDelete = config?.Contexts[activeRowIndex].Name
        
        config?.Contexts.remove(at: activeRowIndex)
        removeUnusedClustersAndUsers()
        
        var latestConfig:Config!
        do {
            latestConfig = try k8s.getConfig()
        } catch {
            NSLog("Not able to get latest config \(error))")
        }
        
        activeRowIndex = (config?.Contexts.count)! - 1
        if contextToDelete == latestConfig.CurrentContext {
            let newCurrentContext = config.Contexts[activeRowIndex].Name
            config.CurrentContext = newCurrentContext
        }
        refreshTable()
        
        applyButton.isEnabled = true
        revertButton.isEnabled = true
    }
    
    func importContext() {
        NSLog("will import file...")
        if k8s == nil {
            NSLog("Not able to import config file, kubernetes not initialized!")
            return
        }
        var configToImportFileUrl: URL?
        if testFileToImport == nil {
            configToImportFileUrl = openFolderSelection()
        } else {
            configToImportFileUrl = testFileToImport
        }
        if configToImportFileUrl == nil {
            NSLog("Not able to import config file, could not access file!")
            return
        }
        do {
            config = try k8s.mergeKubeconfigIntoConfig(configToImportFileUrl: configToImportFileUrl!, mainConfig: config!)
        } catch {
            NSLog("Could not merge imported config file\(error))")
        }
        NSLog("imported!")
        refreshTable()
        applyButton.isEnabled = true
        revertButton.isEnabled = true
    }
    @IBAction func importRestoreClicked(_ sender: Any) {
        if (importButtonAction == "import") {
            importContext()
        } else if (importButtonAction == "restore") {
            let alert = NSAlert()
            alert.icon = NSImage.init(named: NSImage.cautionName)
            alert.messageText = "Are you sure?"
            alert.informativeText = "This will restore your kubeconfig file to its original state. You will lose any changes you made after you pointed your kubeconfig file to the app."
            alert.addButton(withTitle: "No")
            alert.addButton(withTitle: "Yes")
            alert.beginSheetModal(for: self.view.window!) { (returnCode: NSApplication.ModalResponse) -> Void in
                NSLog ("Restore confirmation returnCode: \(returnCode)")
                if returnCode == NSApplication.ModalResponse(rawValue: 1001) {
                    self.restoreOriginal()
                }
            }
        }
    }
    
    func restoreOriginal() {
        do {
            let kubeconfigFileUrl = loadBookmarks()
            let origConfigURL = getOrigKubeconfigFileUrl()
            let _ = try fileManager.replaceItemAt(kubeconfigFileUrl!, withItemAt: origConfigURL!, backupItemName: "kubeconfig.kubecontext")
            k8s.kubeconfig = nil
            let alert = NSAlert()
            alert.icon = NSImage.init(named: NSImage.cautionName)
            alert.messageText = "Restored to original kubeconfig file!"
            alert.addButton(withTitle: "OK")
            alert.runModal()
            self.view.window?.close()
        } catch {
            NSLog("Error: Could not restore to original kubeconfig file: \(error)")
        }
    }
    
    @IBAction func changeKubeconfigAction(_ sender: Any) {
        do {
            try selectKubeconfigFile()
            freshReload()
        } catch {
            alertUserWithWarning(message: "Could not parse selected kubeconfig file\n \(error)")
        }
    }
    
    @IBAction func showContextAction(_ sender: Any) {
        if showContextCheckbox.state == .off {
            UserDefaults.standard.set(false, forKey: keyShowContextOnMenu)
            k8s.setShowContextName(show: false)
        } else if showContextCheckbox.state == .on {
            UserDefaults.standard.set(true, forKey: keyShowContextOnMenu)
            k8s.setShowContextName(show: true)
        }
    }
    
    @IBAction func lockButtonAction(_ sender: Any) {
        if proProductPriceString == "" {
            return
        }
        let alert = NSAlert()
        alert.icon = NSImage.init(named: NSImage.cautionName)
        alert.messageText = "Purchase Full Version"
        alert.informativeText = "This will enable you to upgrade to the full version and use all features and functions.\n\n" +
            "For " + proProductPriceString
        alert.addButton(withTitle: "No")
        alert.addButton(withTitle: "Yes")
        alert.beginSheetModal(for: self.view.window!) { (returnCode: NSApplication.ModalResponse) -> Void in
            NSLog ("Restore confirmation returnCode: \(returnCode)")
            if returnCode == NSApplication.ModalResponse(rawValue: 1001) {
                SwiftyStoreKit.purchaseProduct(proProductId, quantity: 1, atomically: true) { result in
                    switch result {
                    case .success(let purchase):
                        NSLog("Purchase Success: \(purchase.productId)")
                        UserDefaults.standard.set(true, forKey: keyPro)
                        DispatchQueue.main.async {
                            self.unlock()
                        }
                    case .error(let error):
                        switch error.code {
                        case .unknown: NSLog("Unknown error. Please contact support")
                        case .clientInvalid: NSLog("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: NSLog("The purchase identifier was invalid")
                        case .paymentNotAllowed: NSLog("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: NSLog("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: NSLog("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: NSLog("Could not connect to the network")
                        case .cloudServiceRevoked: NSLog("User has revoked permission to use this cloud service")
                        default: NSLog((error as NSError).localizedDescription)
                        }
                    }
                }

            }
        }
    }
    
    
}

extension ManageViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        if let _ = notification.object as? NSTextField {
            applyButton.isEnabled = true
            revertButton.isEnabled = true
            //do what you need here
        }
    }
}

extension ManageViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return contexts?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        
        let item = NSPasteboardItem()
        item.setString(String(row), forType: self.dragDropType)
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
            if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }
        
        var oldIndexOffset = 0
        var newIndexOffset = 0
        
        // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
        // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                let fromIndex = oldIndex + oldIndexOffset
                let toIndex = row - 1
                
                tableView.moveRow(at: fromIndex, to: toIndex)
                let c = config?.Contexts.remove(at: fromIndex)
                config?.Contexts.insert(c!, at: toIndex)
                oldIndexOffset -= 1
                if activeRowIndex == fromIndex {
                    activeRowIndex = toIndex
                } else if row > activeRowIndex && oldIndex < activeRowIndex {
                    activeRowIndex = activeRowIndex - 1
                }
            } else {
                let fromIndex = oldIndex
                let toIndex = row + newIndexOffset
                
                tableView.moveRow(at: fromIndex, to: toIndex)
                let c = config?.Contexts.remove(at: fromIndex)
                config?.Contexts.insert(c!, at: toIndex)
                newIndexOffset += 1
                
                if activeRowIndex == fromIndex {
                    activeRowIndex = toIndex
                } else if row <= activeRowIndex &&  oldIndex > activeRowIndex {
                    activeRowIndex = activeRowIndex + 1
                }
            }
        }
        tableView.selectRowIndexes(NSIndexSet(index: activeRowIndex) as IndexSet, byExtendingSelection: false)
        loadConfig()
        tableView.endUpdates()
        applyButton.isEnabled = true
        revertButton.isEnabled = true
        return true
    }
}

extension ManageViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        
        // 1
        guard let item = contexts?[row] else {
            return nil
        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = item.Name.truncated(limit: 26, position: .middle, leader: "...")
        } else {
            NSLog("Unknown column id")
            return nil
        }
        
        // 3
        if let cell = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
