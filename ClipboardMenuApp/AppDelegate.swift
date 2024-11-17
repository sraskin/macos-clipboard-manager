import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var clipboardManager = ClipboardManager()
    var eventMonitor: Any?


    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView(clipboardManager: clipboardManager))

        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
            statusBarButton.action = #selector(togglePopover(_:))
        }
        
        // Hide the Dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Add event monitor to close popover when clicking outside
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(event)
            }
            return event
        }
        
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }


    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let statusBarButton = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: .minY)
            }
        }
    }


//    func applicationWillTerminate(_ notification: Notification) {
//        if let contentViewController = popover.contentViewController as? NSHostingController<ContentView> {
//            contentViewController.rootView.clipboardManager.stopMonitoring()
//        }
//    }

//    func applicationWillTerminate(_ notification: Notification) {
//            clipboardManager.stopMonitoring()
//        }
}
