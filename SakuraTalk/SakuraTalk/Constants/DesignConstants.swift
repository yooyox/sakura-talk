import SwiftUI

// MARK: - 圆角规范
struct CornerRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
}

// MARK: - 间距规范
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - 字号规范
struct FontSize {
    static let title: CGFloat = 28
    static let pageTitle: CGFloat = 22
    static let sectionTitle: CGFloat = 18
    static let body: CGFloat = 16
    static let subhead: CGFloat = 14
    static let caption: CGFloat = 12
}

// MARK: - 动画时长
struct AnimationDuration {
    static let fast: Double = 0.2
    static let normal: Double = 0.3
    static let slow: Double = 0.5
}