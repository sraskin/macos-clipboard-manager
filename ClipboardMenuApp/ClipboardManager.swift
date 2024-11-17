import Foundation
import AppKit

class ClipboardManager: ObservableObject {
    @Published var copiedTexts: [String] = []

    private var changeCount = NSPasteboard.general.changeCount
    private var timer: Timer?
    private var lastCopiedByApp: String?


    init() {
        startMonitoring()
    }

    func startMonitoring() {
        // Check the clipboard every 0.5 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func clearCopiedTexts() {
        DispatchQueue.main.async {
            self.copiedTexts.removeAll()
        }
    }
    
    func copyTextToClipboard(_ text: String) {
        lastCopiedByApp = text
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    @objc private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount
            if let copiedString = pasteboard.string(forType: .string) {
                if copiedString == lastCopiedByApp {
                    lastCopiedByApp = nil
                    return
                }
                DispatchQueue.main.async {
                    if self.copiedTexts.first != copiedString {
                        self.copiedTexts.insert(copiedString, at: 0)
                    }
                }
            }
        }
    }
}
