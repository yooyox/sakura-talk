import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ConversationView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "bubble.left.and.bubble.right")
                        Text("对话")
                    }
                }

            CameraView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "camera")
                        Text("拍照")
                    }
                }

            HistoryView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("历史")
                    }
                }
        }
        .tint(.black)
    }
}

// MARK: - 对话视图
struct ConversationView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // 空状态
                VStack(spacing: 24) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(.black.opacity(0.2))

                    VStack(spacing: 8) {
                        Text("开始对话")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.black)

                        Text("点击下方按钮开始翻译对话")
                            .font(.system(size: 15))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                }

                Spacer()

                // 底部按钮
                VStack(spacing: 12) {
                    Button {
                        // 文字输入
                    } label: {
                        HStack {
                            Image(systemName: "keyboard")
                            Text("文字输入")
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        // 语音输入
                    } label: {
                        HStack {
                            Image(systemName: "mic")
                            Text("语音对话")
                        }
                        .font(.system(size: 17))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("对话")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
        }
    }
}

// MARK: - 拍照视图
struct CameraView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // 相机取景框
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.black.opacity(0.1), lineWidth: 1)
                    .frame(height: 320)
                    .overlay {
                        VStack(spacing: 16) {
                            Image(systemName: "camera")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.black.opacity(0.2))

                            Text("拍摄需要翻译的内容")
                                .font(.system(size: 15))
                                .foregroundStyle(.black.opacity(0.4))
                        }
                    }
                    .padding(.horizontal, 24)

                Spacer()

                // 底部按钮
                HStack(spacing: 20) {
                    Button {
                        // 相册
                    } label: {
                        Image(systemName: "photo")
                            .font(.system(size: 22))
                            .foregroundStyle(.black.opacity(0.6))
                            .frame(width: 48, height: 48)
                    }

                    Button {
                        // 拍照
                    } label: {
                        Circle()
                            .fill(.black)
                            .frame(width: 72, height: 72)
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            }
                    }

                    Button {
                        // 闪光灯
                    } label: {
                        Image(systemName: "bolt")
                            .font(.system(size: 22))
                            .foregroundStyle(.black.opacity(0.6))
                            .frame(width: 48, height: 48)
                    }
                }
                .padding(.bottom, 48)
            }
            .background(.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("拍照")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
        }
    }
}

// MARK: - 历史视图
struct HistoryView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    Image(systemName: "clock")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(.black.opacity(0.2))

                    VStack(spacing: 8) {
                        Text("暂无记录")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.black)

                        Text("翻译记录会保存在这里")
                            .font(.system(size: 15))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("历史")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}