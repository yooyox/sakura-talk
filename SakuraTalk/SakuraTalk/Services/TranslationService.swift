import Foundation
import Translation

/// 翻译服务 - 封装 Apple Translation Framework
/// 注意：Translation Framework 需要 iOS 26+ 和真机测试
@available(iOS 26.0, *)
class TranslationService {
    static let shared = TranslationService()

    private init() {}

    /// 翻译文本
    /// - Parameters:
    ///   - text: 待翻译的文本
    ///   - sourceLanguage: 源语言
    ///   - targetLanguage: 目标语言
    /// - Returns: 翻译后的文本
    func translate(
        text: String,
        from sourceLanguage: Locale.Language,
        to targetLanguage: Locale.Language
    ) async throws -> String {
        // 创建翻译会话（直接传入语言参数）
        let session = TranslationSession(
            installedSource: sourceLanguage,
            target: targetLanguage
        )

        // 执行翻译
        let response = try await session.translate(text)

        return response.targetText
    }

    /// 翻译中文到日文
    /// - Parameter text: 中文文本
    /// - Returns: 日文翻译
    func translateChineseToJapanese(_ text: String) async throws -> String {
        let chinese = Locale.Language(identifier: "zh-Hans")
        let japanese = Locale.Language(identifier: "ja")
        return try await translate(text: text, from: chinese, to: japanese)
    }

    /// 翻译日文到中文
    /// - Parameter text: 日文文本
    /// - Returns: 中文翻译
    func translateJapaneseToChinese(_ text: String) async throws -> String {
        let japanese = Locale.Language(identifier: "ja")
        let chinese = Locale.Language(identifier: "zh-Hans")
        return try await translate(text: text, from: japanese, to: chinese)
    }
}

// MARK: - 错误类型
enum TranslationError: LocalizedError {
    case languagePackNotAvailable
    case translationFailed(String)
    case emptyInput

    var errorDescription: String? {
        switch self {
        case .languagePackNotAvailable:
            return "语言包未下载，请前往设置下载中日语言包"
        case .translationFailed(let message):
            return "翻译失败：\(message)"
        case .emptyInput:
            return "输入内容为空"
        }
    }
}