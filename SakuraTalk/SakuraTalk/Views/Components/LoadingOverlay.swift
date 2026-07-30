import SwiftUI

/// 加载状态覆盖层
struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            // 半透明黑色背景
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // 加载指示器
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)

                Text(message)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }
}

#Preview {
    LoadingOverlay(message: "正在翻译...")
}