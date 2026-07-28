import Foundation
import SwiftData

/// 拍照翻译记录
@Model
final class PhotoTranslation {
    /// 唯一标识
    var id: UUID
    /// 图片数据
    var imageData: Data?
    /// 识别出的日文原文
    var recognizedText: String
    /// 翻译结果（中文）
    var translatedText: String
    /// 创建时间
    var createdAt: Date
    /// 是否已收藏
    var isFavorite: Bool
    /// 备注信息（可选）
    var note: String?

    init(
        imageData: Data?,
        recognizedText: String,
        translatedText: String,
        note: String? = nil
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.recognizedText = recognizedText
        self.translatedText = translatedText
        self.createdAt = Date()
        self.isFavorite = false
        self.note = note
    }
}

// MARK: - 辅助方法
extension PhotoTranslation {
    /// 格式化的时间显示
    var formattedDate: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(createdAt) {
            return "今天 " + formatDate(timeStyle: .short)
        } else if calendar.isDateInYesterday(createdAt) {
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
        return formatter.string(from: createdAt)
    }

    /// 翻译文本预览（前30个字符）
    var textPreview: String {
        let text = translatedText
        let limit = 30
        if text.count <= limit {
            return text
        } else {
            return String(text.prefix(limit)) + "..."
        }
    }
}