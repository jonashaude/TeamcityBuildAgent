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
    var applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.path + "/teamcityBuildAgent/"
    
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
                var path = result!.path
                if (fileManager.fileExists(atPath: "\(path)/bin/agent.sh")){
                    
                    path = path.replacingOccurrences(of: " ", with: "\\ ")
                    shell("cp -r '\(path)' '\(applicationSupport)'")
                    
                    
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
        if(sender.title == "Run"){
            logTextView.string += "\n -------Start Agent------- \n"
            shell("cd '\(applicationSupport)/buildAgent/bin/' && sh agent.sh start")
            sender.title = "Stop"
        }else {
            logTextView.string += "\n -------Stop Agent------- \n"
            shell("cd '\(applicationSupport)/buildAgent/bin/' && sh agent.sh stop")
            sender.title = "Run"
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(applicationSupport)
        if (!fileManager.fileExists(atPath: applicationSupport)) {
            do {
                try FileManager.default.createDirectory(atPath: applicationSupport, withIntermediateDirectories: false, attributes: .none)
            }catch {
                print(error)
            }
        }else {
            selectButton.isEnabled = false
            runButton.isEnabled = true
        }
        
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

        let data = pipe.fileHandleForReading
        data.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                // Update your view with the new text here
                
                DispatchQueue.main.sync {
                    self.logTextView.string += line
                    self.logTextView.scrollToEndOfDocument(self)
                }
                
            } else {
                print("Error decoding data: \(pipe.availableData)")
            }
        }
    }
}

