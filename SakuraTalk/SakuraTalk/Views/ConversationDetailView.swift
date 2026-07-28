import SwiftUI
import SwiftData

/// 对话记录详情页
struct ConversationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    let conversation: Conversation

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(conversation.messages) { message in
                    MessageBubbleView(message: message)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .background(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(conversation.displayTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.black.opacity(0.6))
                }
            }
        }
        .confirmationDialog("删除对话记录", isPresented: $showDeleteConfirmation) {
            Button("删除", role: .destructive) {
                deleteConversation()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要删除这条对话记录吗？此操作无法撤销。")
        }
    }

    private func deleteConversation() {
        modelContext.delete(conversation)
        do {
            try modelContext.save()
        } catch {
            print("删除失败: \(error.localizedDescription)")
        }
        dismiss()
    }
}

// MARK: - 消息气泡视图
struct MessageBubbleView: View {
    let message: Message

    var body: some View {
        HStack {
            if message.displayPosition == .left {
                Spacer()
            }

            VStack(alignment: message.displayPosition == .left ? .leading : .trailing, spacing: 8) {
                // 语言标记
                HStack(spacing: 4) {
                    if message.displayPosition == .left {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(.red)

                        Text("日语")
                            .font(.system(size: 12))
                            .foregroundStyle(.black.opacity(0.4))
                    } else {
                        Text("中文")
                            .font(.system(size: 12))
                            .foregroundStyle(.black.opacity(0.4))

                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(.blue)
                    }
                }

                // 原文
                Text(message.sourceText)
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(message.displayPosition == .left ? .leading : .trailing)

                // 分隔线
                Rectangle()
                    .fill(.black.opacity(0.1))
                    .frame(height: 1)

                // 翻译结果
                Text(message.translatedText)
                    .font(.system(size: 16))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(message.displayPosition == .left ? .leading : .trailing)

                // 时间戳和来源
                HStack(spacing: 8) {
                    Text(formatTime(message.createdAt))
                        .font(.system(size: 11))
                        .foregroundStyle(.black.opacity(0.3))

                    if message.isFromVoice {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.black.opacity(0.3))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(message.displayPosition == .left
                        ? Color.black.opacity(0.02)
                        : Color.black.opacity(0.04))
            )

            if message.displayPosition == .right {
                Spacer()
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ConversationDetailView(conversation: {
            let conversation = Conversation(title: "测试对话")
            conversation.addMessage(Message(
                sourceText: "すみません、メニューを見せてください",
                sourceLanguage: .japanese,
                translatedText: "不好意思，请给我看看菜单",
                targetLanguage: .chinese
            ))
            conversation.addMessage(Message(
                sourceText: "好的，这是菜单",
                sourceLanguage: .chinese,
                translatedText: "はい、メニューです",
                targetLanguage: .japanese
            ))
            return conversation
        }())
    }
    .modelContainer(for: Conversation.self, inMemory: true)
}