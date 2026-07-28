import SwiftUI
import SwiftData

/// 拍照翻译详情页
struct PhotoTranslationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showShareSheet = false
    @State private var isZoomed = false

    let photoTranslation: PhotoTranslation

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 原图
                if let imageData = photoTranslation.imageData,
                   let uiImage = UIImage(data: imageData) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("原图")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 24)

                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 24)
                            .onTapGesture {
                                withAnimation {
                                    isZoomed.toggle()
                                }
                            }
                    }
                }

                // 识别结果
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 14))
                            Text("识别结果（日文）")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)

                        Spacer()

                        // 复制按钮
                        Button {
                            UIPasteboard.general.string = photoTranslation.recognizedText
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16))
                                .foregroundStyle(.black.opacity(0.6))
                        }
                    }

                    Text(photoTranslation.recognizedText)
                        .font(.system(size: 16))
                        .foregroundStyle(.black.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.02))
                        )
                }
                .padding(.horizontal, 24)

                // 翻译结果
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "character.bubble")
                                .font(.system(size: 14))
                            Text("翻译结果（中文）")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)

                        Spacer()

                        // 复制按钮
                        Button {
                            UIPasteboard.general.string = photoTranslation.translatedText
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16))
                                .foregroundStyle(.black.opacity(0.6))
                        }
                    }

                    Text(photoTranslation.translatedText)
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.04))
                        )
                }
                .padding(.horizontal, 24)

                // 备注信息
                if let note = photoTranslation.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "note.text")
                                .font(.system(size: 14))
                            Text("备注")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)

                        Text(note)
                            .font(.system(size: 15))
                            .foregroundStyle(.black.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.02))
                            )
                    }
                    .padding(.horizontal, 24)
                }

                // 时间信息
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(photoTranslation.formattedDate)
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(.black.opacity(0.4))

                    if photoTranslation.isFavorite {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                            Text("已收藏")
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(Color.morandiRed)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .background(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("拍照翻译")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    // 收藏/取消收藏
                    Button {
                        photoTranslation.isFavorite.toggle()
                        try? modelContext.save()
                    } label: {
                        Label(
                            photoTranslation.isFavorite ? "取消收藏" : "收藏",
                            systemImage: photoTranslation.isFavorite ? "heart.slash" : "heart"
                        )
                    }

                    // 分享
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }

                    Divider()

                    // 删除
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.black.opacity(0.6))
                }
            }
        }
        .confirmationDialog("删除拍照翻译", isPresented: $showDeleteConfirmation) {
            Button("删除", role: .destructive) {
                deletePhotoTranslation()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要删除这条拍照翻译记录吗？此操作无法撤销。")
        }
        .sheet(isPresented: $showShareSheet) {
            if let imageData = photoTranslation.imageData {
                ShareSheet(items: [
                    "原文：\(photoTranslation.recognizedText)\n翻译：\(photoTranslation.translatedText)"
                ])
            }
        }
    }

    private func deletePhotoTranslation() {
        modelContext.delete(photoTranslation)
        do {
            try modelContext.save()
        } catch {
            print("删除失败: \(error.localizedDescription)")
        }
        dismiss()
    }
}

// MARK: - 分享表单
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        PhotoTranslationDetailView(photoTranslation: PhotoTranslation(
            imageData: nil,
            recognizedText: "ラーメン（味玉入）",
            translatedText: "拉面（加味玉）",
            note: "这是一家拉面店的菜单"
        ))
    }
    .modelContainer(for: PhotoTranslation.self, inMemory: true)
}