//
//  KubeContextUITests.swift
//  KubeContextUITests
//
//  Created by Turken, Hasan on 20.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import XCTest

class KubeContextUITests: XCTestCase {
    var app: XCUIApplication!
    let fileManager = FileManager.default
    var bundle: Bundle!
    var bundleBeingTested: Bundle!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        
        app.launch()
        

        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let menuBarsQuery = app.menuBars
        menuBarsQuery.menuItems["Select kubeconfig file"].click()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let menuBarsQuery = app.menuBars
        let manageContextsMenuItem = menuBarsQuery/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        manageContextsMenuItem.click()
        let contextManagementWindow = app.windows["Context Management"]
        let xcuiClosewindowButton = contextManagementWindow.buttons[XCUIIdentifierCloseWindow]
        XCUIElement.perform(withKeyModifiers: .option) {
            contextManagementWindow.buttons["Restore Original"].click()
        }
        
        let alertSheet = contextManagementWindow.sheets["alert"]
        alertSheet.buttons["Yes"].click()
        XCUIApplication().dialogs["alert"].buttons["OK"].click()
        
        
    }

    func testChangeContext() {
        let app = XCUIApplication()
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let menuBarsQuery = app.menuBars
        let currentContextMenusQuery = menuBarsQuery/*@START_MENU_TOKEN@*/.menus.containing(.menuItem, identifier:"Current Context")/*[[".statusItems",".menus.containing(.menuItem, identifier:\"Quit\")",".menus.containing(.menuItem, identifier:\"Manage Contexts\")",".menus.containing(.menuItem, identifier:\"Import Kubeconfig File\")",".menus.containing(.menuItem, identifier:\"Switch Context\")",".menus.containing(.menuItem, identifier:\"Current Context\")"],[[[-1,5],[-1,4],[-1,3],[-1,2],[-1,1],[-1,0,1]],[[-1,5],[-1,4],[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        currentContextMenusQuery.children(matching: .menuItem)["docker-for-desktop"].click()
        statusItem.click()
        menuBarsQuery.menuItems["Switch Context"].click()
        menuBarsQuery.menus.menuItems["minikube"].click()
        statusItem.click()
        currentContextMenusQuery.children(matching: .menuItem)["minikube"].click()
        
        print("ok")
    }
    
    func testRenameContext() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        
        statusItem.click()
        let menuBarsQuery = app.menuBars
        let manageContextsMenuItem = menuBarsQuery/*@START_MENU_TOKEN@*/.menus.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[1]]@END_MENU_TOKEN@*/
        manageContextsMenuItem.click()

        
        let contextManagementWindow = app.windows["Context Management"]
        let textField = contextManagementWindow.groups.containing(.textField, identifier:"default").children(matching: .textField).element(boundBy: 0)
        textField.click()
        textField.clearText()
        textField.typeText("docker-of-kubernetes")
        
        let applyButton = contextManagementWindow.buttons["Apply"]
        applyButton.click()
        
        let xcuiClosewindowButton = contextManagementWindow.buttons[XCUIIdentifierCloseWindow]
        xcuiClosewindowButton.click()
        statusItem.click()
        let currentContextMenusQuery = menuBarsQuery.menus.containing(.menuItem, identifier:"Current Context")
        currentContextMenusQuery.children(matching: .menuItem)["docker-of-kubernetes"].click()
        statusItem.click()
        manageContextsMenuItem.click()
        contextManagementWindow.tables.staticTexts["prod-cluster"].click()
        textField.click()
        textField.clearText()
        textField.typeText("my-kube")
        applyButton.click()
        xcuiClosewindowButton.click()
        statusItem.click()
        menuBarsQuery.menuItems["Switch Context"].click()
        menuBarsQuery.menuItems["my-kube"].click()
        
        statusItem.click()
        manageContextsMenuItem.click()
        contextManagementWindow.tables.staticTexts["my-kube"].click()
        textField.click()
        textField.clearText()
        textField.typeText("prod-cluster")
        applyButton.click()
        xcuiClosewindowButton.click()
        
        statusItem.click()
        currentContextMenusQuery.children(matching: .menuItem)["prod-cluster"].click()
    }
    
    func testChangeContextDetails() {
        let app = XCUIApplication()
        
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let manageContextsMenuItem = app.menuBars/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        manageContextsMenuItem.click()
        
        let contextManagementWindow = app.windows["Context Management"]
        let gkeDhaasStableStaticText = contextManagementWindow.tables.staticTexts["local-cluster-stable"]
        gkeDhaasStableStaticText.click()
        
        let defaultGroupsQuery = contextManagementWindow.groups.containing(.textField, identifier:"default")
        defaultGroupsQuery.children(matching: .popUpButton).element(boundBy: 0).click()
        
        let minikubeMenuItem = contextManagementWindow/*@START_MENU_TOKEN@*/.menuItems["minikube"]/*[[".groups",".popUpButtons",".menus.menuItems[\"minikube\"]",".menuItems[\"minikube\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/
        minikubeMenuItem.click()
        defaultGroupsQuery.children(matching: .popUpButton).element(boundBy: 1).click()
        minikubeMenuItem.click()
        
        let defaultTextField = contextManagementWindow/*@START_MENU_TOKEN@*/.textFields["default"]/*[[".groups.textFields[\"default\"]",".textFields[\"default\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        defaultTextField.doubleClick()
        defaultTextField.clearText()
        defaultTextField.typeText("newns")
        contextManagementWindow.buttons["Apply"].click()
        
        let xcuiClosewindowButton = contextManagementWindow.buttons[XCUIIdentifierCloseWindow]
        xcuiClosewindowButton.click()
        statusItem.click()
        manageContextsMenuItem.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["minikube"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"minikube\"]",".staticTexts[\"minikube\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        gkeDhaasStableStaticText.click()
        
        let ns_textfieldname = app.textFields["management-name"]
        XCTAssertEqual(ns_textfieldname.value as! String, "local-cluster-stable")
        
        let ns_textfieldns = app.textFields["management-namespace"]
        XCTAssertEqual(ns_textfieldns.value as! String, "newns")
        
        let ns_popcluster = app.popUpButtons["management-popcluster"]
        XCTAssertEqual(ns_popcluster.value as! String, "minikube")
        
        let ns_popuser = app.popUpButtons["management-popuser"]
        XCTAssertEqual(ns_popuser.value as! String, "minikube")
        
        xcuiClosewindowButton.click()
    }
    
    func testRevertChanges() {
        
        let app = XCUIApplication()
        app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0).click()
        app.menuBars/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let contextManagementWindow = app.windows["Context Management"]
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["temp-cluster"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"temp-cluster\"]",".staticTexts[\"temp-cluster\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        let managementNamespaceGroupsQuery = contextManagementWindow/*@START_MENU_TOKEN@*/.groups.containing(.textField, identifier:"management-namespace")/*[[".groups.containing(.textField, identifier:\"default\")",".groups.containing(.textField, identifier:\"management-namespace\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let textField = managementNamespaceGroupsQuery.children(matching: .textField).element(boundBy: 0)
        textField.click()
        textField.clearText()
        textField.typeText("permanent-cluster")
        managementNamespaceGroupsQuery.children(matching: .popUpButton).element(boundBy: 0).click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.menuItems["docker-for-desktop-cluster"]/*[[".groups",".popUpButtons",".menus.menuItems[\"docker-for-desktop-cluster\"]",".menuItems[\"docker-for-desktop-cluster\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.click()
        managementNamespaceGroupsQuery.children(matching: .popUpButton).element(boundBy: 1).click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.menuItems["real-admin"]/*[[".groups",".popUpButtons",".menus.menuItems[\"real-admin\"]",".menuItems[\"real-admin\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.click()
        let defaultTextField = contextManagementWindow/*@START_MENU_TOKEN@*/.textFields["default"]/*[[".groups.textFields[\"default\"]",".textFields[\"default\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        defaultTextField.doubleClick()
        defaultTextField.clearText()
        defaultTextField.typeText("anotherns")
        contextManagementWindow.buttons["Revert"].click()
        
        let xcuiClosewindowButton = contextManagementWindow.buttons[XCUIIdentifierCloseWindow]
        xcuiClosewindowButton.click()
        
        app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0).click()
        app.menuBars/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["temp-cluster"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"temp-cluster\"]",".staticTexts[\"temp-cluster\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        let ns_textfieldname = app.textFields["management-name"]
        XCTAssertEqual(ns_textfieldname.value as! String, "temp-cluster")
        
        let ns_textfieldns = app.textFields["management-namespace"]
        XCTAssertEqual(ns_textfieldns.value as! String, "default")
        
        let ns_popcluster = app.popUpButtons["management-popcluster"]
        XCTAssertEqual(ns_popcluster.value as! String, "some-other-cluster")
        
        let ns_popuser = app.popUpButtons["management-popuser"]
        XCTAssertEqual(ns_popuser.value as! String, "another-admin")
        
        print("ok")
        
    }
    
    func testAddRemoveContext() {
        print("ok")
        
        let app = XCUIApplication()
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let manageContextsMenuItem = app.menuBars/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        manageContextsMenuItem.click()
        
        let contextManagementWindow = app.windows["Context Management"]
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["minikube"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"minikube\"]",".staticTexts[\"minikube\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        XCUIApplication().windows["Context Management"].groups["add"].children(matching: .button).element(boundBy: 2).click()
        
        let managementNameTextField = contextManagementWindow/*@START_MENU_TOKEN@*/.textFields["management-name"]/*[[".groups.textFields[\"management-name\"]",".textFields[\"management-name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        managementNameTextField.click()
        managementNameTextField.clearText()
        managementNameTextField.typeText("new-kube")
        
        let applyButton = contextManagementWindow.buttons["Apply"]
        applyButton.click()
        
        let xcuiClosewindowButton = contextManagementWindow.buttons[XCUIIdentifierCloseWindow]
        xcuiClosewindowButton.click()
        statusItem.click()
        manageContextsMenuItem.click()
        
        let newMinikubeStaticText = contextManagementWindow.tables.staticTexts["new-kube"]
        newMinikubeStaticText.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["docker-for-desktop"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"docker-for-desktop\"]",".staticTexts[\"docker-for-desktop\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        newMinikubeStaticText.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.buttons["remove"]/*[[".groups.buttons[\"remove\"]",".buttons[\"remove\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        applyButton.click()
        xcuiClosewindowButton.click()
        statusItem.click()
        manageContextsMenuItem.click()
        
        XCTAssert(contextManagementWindow.tables.staticTexts["docker-for-desktop"].exists)
        XCTAssert(contextManagementWindow.tables.staticTexts["minikube"].exists)
        XCTAssert(!contextManagementWindow.tables.staticTexts["new-kube"].exists)
    }
    
    func testRemoveContextWithCleanup() {
        print("ok")
        
        let app = XCUIApplication()
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let manageContextsMenuItem = app.menuBars/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        manageContextsMenuItem.click()
        
        let contextManagementWindow = app.windows["Context Management"]
        contextManagementWindow.tables.staticTexts["test-cluster"].click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.buttons["remove"]/*[[".groups.buttons[\"remove\"]",".buttons[\"remove\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let applyButton = contextManagementWindow.buttons["Apply"]
        applyButton.click()
        
        let expectedContent = try? String(contentsOfFile: "/Users/hasanturken/Workspace/turkenh/KubeContext/KubeContextTests/TestData/ui-test-config-cleaned.yaml", encoding: .utf8)
        
        let currentContent = try? String(contentsOfFile: "/Users/hasanturken/Library/Containers/com.ht.kubecontext/Data/Documents/TempData/ui-test-config.yaml", encoding: .utf8)
        
        XCTAssertEqual(expectedContent!, currentContent!)
    }
    
    func testImportFromMenu() {
        print("ok")
        
        let app = XCUIApplication()
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let menuBarsQuery = app.menuBars
        menuBarsQuery/*@START_MENU_TOKEN@*/.menuItems["Import Kubeconfig File"]/*[[".statusItems",".menus.menuItems[\"Import Kubeconfig File\"]",".menuItems[\"Import Kubeconfig File\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        statusItem.click()
        
        let manageContextsMenuItem = menuBarsQuery/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        manageContextsMenuItem.click()
        
        let contextManagementWindow = app.windows["Context Management"]
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["kubernetes-a...es_imported"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"kubernetes-a...es_imported\"]",".staticTexts[\"kubernetes-a...es_imported\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        let managementNameTextField = contextManagementWindow/*@START_MENU_TOKEN@*/.textFields["management-name"]/*[[".groups.textFields[\"management-name\"]",".textFields[\"management-name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        managementNameTextField.doubleClick()
        managementNameTextField.clearText()
        managementNameTextField.typeText("new-added-context")
        contextManagementWindow.buttons["Apply"].click()
        contextManagementWindow.buttons[XCUIIdentifierCloseWindow].click()
        statusItem.click()
        manageContextsMenuItem.click()
        contextManagementWindow.tables.staticTexts["minikube"].click()
        contextManagementWindow.tables.staticTexts["new-added-context"].click()
        
        let ns_textfieldname = app.textFields["management-name"]
        XCTAssertEqual(ns_textfieldname.value as! String, "new-added-context")
        
        let ns_textfieldns = app.textFields["management-namespace"]
        XCTAssertEqual(ns_textfieldns.value as! String, "")
        
        let ns_popcluster = app.popUpButtons["management-popcluster"]
        XCTAssertEqual(ns_popcluster.value as! String, "kubernetes_imported")
        
        let ns_popuser = app.popUpButtons["management-popuser"]
        XCTAssertEqual(ns_popuser.value as! String, "kubernetes-admin_imported")
        
        contextManagementWindow/*@START_MENU_TOKEN@*/.buttons["remove"]/*[[".groups.buttons[\"remove\"]",".buttons[\"remove\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        let applyButton = contextManagementWindow.buttons["Apply"]
        applyButton.click()
        let xcuiClosewindowButton = contextManagementWindow.buttons[XCUIIdentifierCloseWindow]
        xcuiClosewindowButton.click()
    }
    
    func testImportFromManagement() {
        print("ok")
        
        let app = XCUIApplication()
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let manageContextsMenuItem = app.menuBars/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        manageContextsMenuItem.click()
        
        let contextManagementWindow = app.windows["Context Management"]
        let importKubeconfigButton = XCUIApplication().windows["Context Management"].groups["add"].children(matching: .button).element(boundBy: 0)
        importKubeconfigButton.click()
        
        let applyButton = contextManagementWindow.buttons["Apply"]
        applyButton.click()
        
        let kubernetesAEsImportedStaticText = contextManagementWindow.tables.staticTexts["kubernetes-a...es_imported"]
        kubernetesAEsImportedStaticText.click()
        
        let removeButton = contextManagementWindow/*@START_MENU_TOKEN@*/.buttons["remove"]/*[[".groups.buttons[\"remove\"]",".buttons[\"remove\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        removeButton.click()
        applyButton.click()
        importKubeconfigButton.click()
        applyButton.click()
        
        let xcuiClosewindowButton = contextManagementWindow.buttons[XCUIIdentifierCloseWindow]
        xcuiClosewindowButton.click()
        statusItem.click()
        manageContextsMenuItem.click()
        kubernetesAEsImportedStaticText.click()
        removeButton.click()
        applyButton.click()
        xcuiClosewindowButton.click()
        statusItem.click()
        manageContextsMenuItem.click()
        
        XCTAssert(!contextManagementWindow.tables.staticTexts["kubernetes-a...es_imported"].exists)
        
        xcuiClosewindowButton.click()
    }
    
    func testRestoreOriginal() {
        print("ok")
        
        let app = XCUIApplication()
        let statusItem = app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0)
        statusItem.click()
        
        let menuBarsQuery = app.menuBars
        let manageContextsMenuItem = menuBarsQuery/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        manageContextsMenuItem.click()
        
        let contextManagementWindow = app.windows["Context Management"]
        let removeButton = contextManagementWindow/*@START_MENU_TOKEN@*/.buttons["remove"]/*[[".groups.buttons[\"remove\"]",".buttons[\"remove\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        removeButton.click()
        removeButton.doubleClick()
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["minikube"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"minikube\"]",".staticTexts[\"minikube\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        let managementNameTextField = contextManagementWindow/*@START_MENU_TOKEN@*/.textFields["management-name"]/*[[".groups.textFields[\"management-name\"]",".textFields[\"management-name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        managementNameTextField.doubleClick()
        managementNameTextField.typeText("test")
        
        let applyButton = contextManagementWindow.buttons["Apply"]
        applyButton.click()
        applyButton.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["prod-cluster"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"prod-cluster\"]",".staticTexts[\"prod-cluster\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        let managementPopclusterPopUpButton = contextManagementWindow/*@START_MENU_TOKEN@*/.popUpButtons["management-popcluster"]/*[[".groups.popUpButtons[\"management-popcluster\"]",".popUpButtons[\"management-popcluster\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        managementPopclusterPopUpButton.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.menuItems["minikube"]/*[[".groups",".popUpButtons[\"management-popcluster\"]",".menus.menuItems[\"minikube\"]",".menuItems[\"minikube\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.click()
        applyButton.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["local-cluster"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"local-cluster\"]",".staticTexts[\"local-cluster\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        managementPopclusterPopUpButton.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.menuItems["some-other-cluster"]/*[[".groups",".popUpButtons[\"management-popcluster\"]",".menus.menuItems[\"some-other-cluster\"]",".menuItems[\"some-other-cluster\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.popUpButtons["management-popuser"]/*[[".groups.popUpButtons[\"management-popuser\"]",".popUpButtons[\"management-popuser\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        contextManagementWindow.menuItems["real-admin"].click()
        applyButton.click()
        XCUIApplication().windows["Context Management"].groups["add"].children(matching: .button).element(boundBy: 2).click()
        applyButton.click()
        
        let xcuiClosewindowButton = contextManagementWindow.buttons[XCUIIdentifierCloseWindow]
        xcuiClosewindowButton.click()
        statusItem.click()
        manageContextsMenuItem.click()
        XCUIElement.perform(withKeyModifiers: .option) {
            contextManagementWindow.buttons["Restore Original"].click()
        }
        
        let alertSheet = contextManagementWindow.sheets["alert"]
        alertSheet.buttons["Yes"].click()
        XCUIApplication().dialogs["alert"].buttons["OK"].click()
        
        statusItem.click()
        menuBarsQuery/*@START_MENU_TOKEN@*/.menuItems["Select kubeconfig file"]/*[[".statusItems",".menus.menuItems[\"Select kubeconfig file\"]",".menuItems[\"Select kubeconfig file\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let origContent = try? String(contentsOfFile: "/Users/hasanturken/Workspace/turkenh/KubeContext/KubeContextTests/TestData/ui-test-config.yaml", encoding: .utf8)
        
        let currentContent = try? String(contentsOfFile: "/Users/hasanturken/Library/Containers/com.ht.kubecontext/Data/Documents/TempData/ui-test-config.yaml", encoding: .utf8)
        
        XCTAssertEqual(origContent!, currentContent!)
    }
    
    func testChangeKubeconfig() {
        print("ok")
        
        let app = XCUIApplication()
        app.children(matching: .menuBar).element(boundBy: 1).children(matching: .statusItem).element(boundBy: 0).click()
        
        app.menuBars/*@START_MENU_TOKEN@*/.menuItems["Manage Contexts"]/*[[".statusItems",".menus.menuItems[\"Manage Contexts\"]",".menuItems[\"Manage Contexts\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let contextManagementWindow = app.windows["Context Management"]
        let changeButton = contextManagementWindow.buttons["Change"]
        changeButton.click()
        
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["test-cluster"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"test-cluster\"]",".staticTexts[\"test-cluster\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        contextManagementWindow/*@START_MENU_TOKEN@*/.tables.staticTexts["docker-for-desktop"]/*[[".scrollViews.tables",".tableRows",".cells.staticTexts[\"docker-for-desktop\"]",".staticTexts[\"docker-for-desktop\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        changeButton.click()
        contextManagementWindow.click()
        contextManagementWindow.buttons[XCUIIdentifierCloseWindow].click()
        
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        self.typeText(deleteString)
    }
}
