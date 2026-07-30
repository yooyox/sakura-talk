import SwiftUI

/// 文字选取视图 - 允许用户长按选取并复制文字
struct TextSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let message: Message

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 原文
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.sourceLanguage.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.black.opacity(0.4))

                        Text(message.sourceText)
                            .font(.system(size: 17))
                            .foregroundStyle(.black)
                            .textSelection(.enabled)
                    }

                    Divider()

                    // 译文
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.targetLanguage.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.black.opacity(0.4))

                        Text(message.translatedText)
                            .font(.system(size: 17))
                            .foregroundStyle(.black.opacity(0.7))
                            .textSelection(.enabled)
                    }
                }
                .padding(24)
            }
            .background(.white)
            .navigationTitle("选取文字")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundStyle(.black)
                }
            }
        }
    }
}