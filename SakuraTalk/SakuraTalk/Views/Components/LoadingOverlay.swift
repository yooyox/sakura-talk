import SwiftUI

/// 加载状态覆盖层（轻量，不遮挡屏幕）
struct LoadingOverlay: View {
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            ProgressView()
                .scaleEffect(1.1)
                .tint(.black.opacity(0.6))

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(.black.opacity(0.5))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
    }
}

#Preview {
    LoadingOverlay(message: "正在翻译...")
}