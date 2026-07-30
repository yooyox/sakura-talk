import Foundation

/// 语言检测工具 - 自动识别输入文本的语言
struct LanguageDetector {

    /// 检测文本语言（中文 or 日文）
    /// - Parameter text: 输入文本
    /// - Returns: 检测到的语言
    static func detect(_ text: String) -> Language {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .chinese }

        var japaneseCount = 0
        var chineseCount = 0

        for scalar in trimmed.unicodeScalars {
            let value = scalar.value

            // 平假名: U+3040 - U+309F
            // 片假名: U+30A0 - U+30FF
            // 片假名扩展: U+31F0 - U+31FF
            // 半角片假名: U+FF65 - U+FF9F
            if (0x3040...0x309F).contains(value) ||
               (0x30A0...0x30FF).contains(value) ||
               (0x31F0...0x31FF).contains(value) ||
               (0xFF65...0xFF9F).contains(value) {
                japaneseCount += 1
            }
            // CJK 统一汉字: U+4E00 - U+9FFF
            // CJK 扩展 A: U+3400 - U+4DBF
            else if (0x4E00...0x9FFF).contains(value) ||
                    (0x3400...0x4DBF).contains(value) {
                chineseCount += 1
            }
        }

        // 如果包含日文假名，判定为日文
        if japaneseCount > 0 {
            return .japanese
        }

        // 只有汉字，判定为中文
        return .chinese
    }
}