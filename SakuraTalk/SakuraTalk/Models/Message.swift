import Foundation
import SwiftData

/// 语言类型
enum Language: String, Codable, CaseIterable {
    case chinese = "zh"
    case japanese = "ja"

    var displayName: String {
        switch self {
        case .chinese: return "中文"
        case .japanese: return "日语"
        }
    }
}

/// 单条翻译消息
@Model
final class Message {
    /// 唯一标识
    var id: UUID
    /// 原文内容
    var sourceText: String
    /// 原文语言
    var sourceLanguage: Language
    /// 翻译结果
    var translatedText: String
    /// 目标语言
    var targetLanguage: Language
    /// 创建时间
    var createdAt: Date
    /// 是否来自语音识别
    var isFromVoice: Bool
    /// 音频文件路径（如果有）
    var audioPath: URL?

    init(
        sourceText: String,
        sourceLanguage: Language,
        translatedText: String,
        targetLanguage: Language,
        isFromVoice: Bool = false,
        audioPath: URL? = nil
    ) {
        self.id = UUID()
        self.sourceText = sourceText
        self.sourceLanguage = sourceLanguage
        self.translatedText = translatedText
        self.targetLanguage = targetLanguage
        self.createdAt = Date()
        self.isFromVoice = isFromVoice
        self.audioPath = audioPath
    }
}

// MARK: - 辅助方法
extension Message {
    /// 是否是中文原文
    var isChineseSource: Bool {
        return sourceLanguage == .chinese
    }

    /// 显示位置（左侧：日本人，右侧：中国人）
    /// 中文原文显示在右侧，日文原文显示在左侧
    var displayPosition: MessagePosition {
        return isChineseSource ? .right : .left
    }
}

/// 消息显示位置
enum MessagePosition {
    case left   // 日文消息
    case right  // 中文消息
}