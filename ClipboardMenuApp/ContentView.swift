import SwiftUI

struct ContentView: View {
    @ObservedObject var clipboardManager: ClipboardManager
    @State private var copiedText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    clipboardManager.clearCopiedTexts()
                }) {
                    Text("Clear Clipboard")
                        .font(.system(size: 12))
                }
                .padding(.trailing, 10)
                .padding(.top, 10)
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(clipboardManager.copiedTexts.enumerated()), id: \.offset) { index, text in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(text.count > 40 ? "\(text.prefix(50))..." : text)
                                .font(.system(size: 12))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(copiedText == text ? Color.blue.opacity(0.2) : Color.clear)
                                .onTapGesture {
                                    clipboardManager.copyTextToClipboard(text)
                                    copiedText = text
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        copiedText = ""
                                    }
                                }

                            if index < clipboardManager.copiedTexts.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
            .frame(width: 300, height: 550)

            Spacer()
        }
        .frame(width: 300, height: 600)
    }

}
