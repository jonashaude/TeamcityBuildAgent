//
//  ViewController.swift
//  TeamcityBuildAgent
//
//  Created by Jonas Haude on 04.09.19.
//  Copyright © 2019 Jonas Haude. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController {
    let fileManager = FileManager()
    
    
    var buildAgentPath = ""
    
    @IBOutlet weak var pathLabel: NSTextField!
    
    @IBOutlet var logTextView: NSTextView!
    
    @IBOutlet weak var selectButton: NSButton!
    @IBOutlet weak var runButton: NSButton!
    
    @IBAction func selectFile(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose BuildAgent Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.canChooseFiles          = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["zip"];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                if (fileManager.fileExists(atPath: "\(path)/bin/agent.sh")){
                    pathLabel.stringValue = path
                    buildAgentPath = path
                    runButton.isEnabled = true
                }else {
                    pathLabel.stringValue = "Not a valid buildAgent Folder!"
                }
                
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
    
    @IBAction func run(_ sender: NSButton) {
        shell("cd \(buildAgentPath)/bin/ && sh agent.sh run")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func shell(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        logTextView.string += output
    }
}

