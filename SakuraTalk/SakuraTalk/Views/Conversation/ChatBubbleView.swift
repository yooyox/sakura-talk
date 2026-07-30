import SwiftUI

/// 聊天气泡视图 - 微信风格
/// 左侧：日文消息（日本人说的）
/// 右侧：中文消息（中国人说的）
struct ChatBubbleView: View {
    let message: Message

    private var isChinese: Bool {
        message.sourceLanguage == .chinese
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isChinese {
                Spacer(minLength: 64)
            }

            VStack(alignment: isChinese ? .trailing : .leading, spacing: 6) {
                // 原文（支持文字选取）
                Text(message.sourceText)
                    .font(.system(size: 16))
                    .foregroundStyle(isChinese ? .white : .black)
                    .multilineTextAlignment(isChinese ? .trailing : .leading)
                    .textSelection(.enabled)

                // 分隔线
                Rectangle()
                    .fill(isChinese ? Color.white.opacity(0.25) : Color.black.opacity(0.08))
                    .frame(height: 0.5)

                // 翻译结果（支持文字选取）
                Text(message.translatedText)
                    .font(.system(size: 15))
                    .foregroundStyle(isChinese ? Color.white.opacity(0.85) : .black.opacity(0.55))
                    .multilineTextAlignment(isChinese ? .trailing : .leading)
                    .textSelection(.enabled)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isChinese ? Color.hazeBlueGreen : .white)
                    .shadow(color: .black.opacity(isChinese ? 0 : 0.04), radius: 2, y: 1)
            )

            if !isChinese {
                Spacer(minLength: 64)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 预览
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView(message: Message(
                sourceText: "你好，请问这个多少钱？",
                sourceLanguage: .chinese,
                translatedText: "こんにちは、これはいくらですか？",
                targetLanguage: .japanese
            ))

            ChatBubbleView(message: Message(
                sourceText: "これは1000円です",
                sourceLanguage: .japanese,
                translatedText: "这是1000日元",
                targetLanguage: .chinese
            ))

            ChatBubbleView(message: Message(
                sourceText: "好的，我要两个",
                sourceLanguage: .chinese,
                translatedText: "はい、2つください",
                targetLanguage: .japanese
            ))
        }
        .padding(.vertical)
    }
    .background(Color(hex: "F5F5F5"))
}