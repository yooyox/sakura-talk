import Foundation
import SwiftData
import SwiftUI

/// 历史记录视图模型
@Observable
class HistoryViewModel {
    // MARK: - 属性
    private var modelContext: ModelContext

    /// 对话记录列表
    var conversations: [Conversation] = []

    /// 拍照翻译记录列表
    var photoTranslations: [PhotoTranslation] = []

    /// 是否有数据
    var hasData: Bool {
        return !conversations.isEmpty || !photoTranslations.isEmpty
    }

    // MARK: - 初始化
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }

    // MARK: - 数据操作

    /// 获取所有数据
    func fetchData() {
        fetchConversations()
        fetchPhotoTranslations()
    }

    /// 获取对话记录
    func fetchConversations() {
        let descriptor = FetchDescriptor<Conversation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        do {
            conversations = try modelContext.fetch(descriptor)
        } catch {
            print("获取对话记录失败: \(error.localizedDescription)")
        }
    }

    /// 获取拍照翻译记录
    func fetchPhotoTranslations() {
        let descriptor = FetchDescriptor<PhotoTranslation>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            photoTranslations = try modelContext.fetch(descriptor)
        } catch {
            print("获取拍照翻译记录失败: \(error.localizedDescription)")
        }
    }

    /// 删除对话记录
    func deleteConversation(_ conversation: Conversation) {
        modelContext.delete(conversation)
        saveChanges()
        fetchConversations()
    }

    /// 删除拍照翻译记录
    func deletePhotoTranslation(_ photoTranslation: PhotoTranslation) {
        modelContext.delete(photoTranslation)
        saveChanges()
        fetchPhotoTranslations()
    }

    /// 清空所有对话记录
    func clearAllConversations() {
        for conversation in conversations {
            modelContext.delete(conversation)
        }
        saveChanges()
        fetchConversations()
    }

    /// 清空所有拍照翻译记录
    func clearAllPhotoTranslations() {
        for photoTranslation in photoTranslations {
            modelContext.delete(photoTranslation)
        }
        saveChanges()
        fetchPhotoTranslations()
    }

    /// 切换收藏状态
    func toggleFavorite(_ photoTranslation: PhotoTranslation) {
        photoTranslation.isFavorite.toggle()
        saveChanges()
        fetchPhotoTranslations()
    }

    // MARK: - 私有方法

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("保存数据失败: \(error.localizedDescription)")
        }
    }
}