import SwiftUI

/// 聊天气泡视图 - 黑白极简风格
/// 左侧：日语气泡（白底黑字）
/// 右侧：中文气泡（灰底黑字，代表"自己"）
struct ChatBubbleView: View {
    let message: Message

    private var isChinese: Bool {
        message.sourceLanguage == .chinese
    }

    /// 不对称圆角：靠近屏幕边缘的上角收窄，形成指向感
    private var bubbleShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: isChinese ? 18 : 4,
            bottomLeadingRadius: 18,
            bottomTrailingRadius: 18,
            topTrailingRadius: isChinese ? 4 : 18
        )
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isChinese {
                Spacer(minLength: 64)
            }

            VStack(alignment: isChinese ? .trailing : .leading, spacing: 6) {
                // 原文
                Text(message.sourceText)
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(isChinese ? .trailing : .leading)

                // 分隔线
                Rectangle()
                    .fill(Color.black.opacity(0.08))
                    .frame(height: 0.5)

                // 翻译结果
                Text(message.translatedText)
                    .font(.system(size: 15))
                    .foregroundStyle(.black.opacity(0.5))
                    .multilineTextAlignment(isChinese ? .trailing : .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                bubbleShape
                    .fill(isChinese ? Color.bubbleGray : .white)
                    .shadow(color: .black.opacity(isChinese ? 0 : 0.04), radius: 2, y: 1)
            )
            .overlay {
                // 白色气泡加发丝描边，在浅灰背景上保持轮廓清晰
                if !isChinese {
                    bubbleShape
                        .strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5)
                }
            }

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