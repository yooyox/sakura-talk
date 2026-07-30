import SwiftUI

// MARK: - 主题颜色（极简黑白风格）
extension Color {
    // MARK: - 主要颜色
    static let primaryText = Color.black
    static let secondaryText = Color.black.opacity(0.5)
    static let tertiaryText = Color.black.opacity(0.3)

    // MARK: - 背景色
    static let background = Color.white
    static let secondaryBackground = Color.black.opacity(0.03)

    // MARK: - 莫兰迪色系
    /// 莫兰迪红色 - 柔和的玫瑰粉红
    static let morandiRed = Color(hex: "C5A3A3")
    /// 莫兰迪灰色 - 柔和的灰
    static let morandiGray = Color(hex: "A3A3A3")

    // MARK: - 强调色（UI 设计规范）
    /// 雾霾蓝绿 - 主按钮、中文气泡
    static let hazeBlueGreen = Color(hex: "7D9B9D")
    /// 气泡灰 - 日语气泡背景
    static let bubbleGray = Color(hex: "F2F2F2")
}

// MARK: - 十六进制初始化
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}