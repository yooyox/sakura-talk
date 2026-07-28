import SwiftUI
import SwiftData

@main
struct SakuraTalkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Conversation.self, Message.self, PhotoTranslation.self])
    }
}