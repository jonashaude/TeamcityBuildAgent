//
//  AppDelegate.swift
//  TeamcityBuildAgent
//
//  Created by Jonas Haude on 04.09.19.
//  Copyright © 2019 Jonas Haude. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSViewController, NSApplicationDelegate {
    
    let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ViewController") as! ViewController
    var statusItem: NSStatusItem?
    
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var mainItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Make a status bar that has variable length (as opposed to being a standard square size)
        // -1 to indicate "variable length"
        print("DID LAUNCH")
        self.statusItem = NSStatusBar.system.statusItem(withLength: -1)
        
        // Set the text that appears in the menu bar
        self.statusItem!.button!.title = "Agent"
        
        // Set the menu that should appear when the item is clicked
        self.statusItem!.menu = self.statusMenu
        
        
        
        self.mainItem.view = self.controller.view
        self.addChild(self.controller)
    
    }
}
