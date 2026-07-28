import Foundation
import SwiftData

/// 对话记录
@Model
final class Conversation {
    /// 唯一标识
    var id: UUID
    /// 对话标题（可选，默认使用第一条消息内容）
    var title: String?
    /// 创建时间
    var createdAt: Date
    /// 更新时间
    var updatedAt: Date
    /// 是否已收藏
    var isFavorite: Bool
    /// 对话中的消息列表
    @Relationship(deleteRule: .cascade)
    var messages: [Message]

    init(title: String? = nil) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = false
        self.messages = []
    }
}

// MARK: - 辅助方法
extension Conversation {
    /// 自动生成标题（使用第一条消息内容）
    var displayTitle: String {
        if let title = title, !title.isEmpty {
            return title
        }

        if let firstMessage = messages.first {
            // 使用第一条消息的前20个字符作为标题
            let text = firstMessage.sourceText
            let limit = 20
            if text.count <= limit {
                return text
            } else {
                return String(text.prefix(limit)) + "..."
            }
        }

        return "新对话"
    }

    /// 消息数量
    var messageCount: Int {
        return messages.count
    }

    /// 最后一条消息时间
    var lastMessageTime: Date {
        return messages.last?.createdAt ?? createdAt
    }

    /// 添加消息
    func addMessage(_ message: Message) {
        messages.append(message)
        updatedAt = Date()
    }

    /// 删除消息
    func removeMessage(_ message: Message) {
        messages.removeAll { $0.id == message.id }
        updatedAt = Date()
    }
}

// MARK: - 时间格式化
extension Conversation {
    /// 格式化的时间显示
    var formattedDate: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(updatedAt) {
            return "今天 " + formatDate(timeStyle: .short)
        } else if calendar.isDateInYesterday(updatedAt) {
            return "昨天 " + formatDate(timeStyle: .short)
        } else {
            return formatDate(dateStyle: .short, timeStyle: .short)
        }
    }

    private func formatDate(dateStyle: DateFormatter.Style = .none, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        return formatter.string(from: updatedAt)
    }
}