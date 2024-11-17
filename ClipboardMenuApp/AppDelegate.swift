import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var clipboardManager = ClipboardManager()
    var eventMonitor: Any?
    var statusMenu: NSMenu!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView(clipboardManager: clipboardManager))

        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
            statusBarButton.action = #selector(statusBarButtonClicked(_:))
            statusBarButton.target = self
            statusBarButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Hide the Dock icon
        NSApp.setActivationPolicy(.accessory)

        // Add local event monitor to close popover when clicking outside
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(event)
            }
            return event
        }

        // Create the status menu
        statusMenu = NSMenu()

        // Create the "Exit" menu item
        let exitMenuItem = NSMenuItem(title: "Exit", action: #selector(exitApp), keyEquivalent: "q")
        exitMenuItem.target = self
        statusMenu.addItem(exitMenuItem)
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            // Show the menu on right-click
            statusItem.popUpMenu(statusMenu)
        } else {
            // Toggle the popover on left-click
            togglePopover(sender)
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

    @objc func exitApp() {
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardManager.stopMonitoring()
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }
}
