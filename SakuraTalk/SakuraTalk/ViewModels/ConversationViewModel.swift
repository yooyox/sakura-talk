import Foundation
import SwiftData

/// 对话业务逻辑 - 双人输入模式
@Observable
class ConversationViewModel {
    // MARK: - 状态
    /// 当前对话的消息列表
    var messages: [Message] = []

    /// 左侧输入框（日文）
    var japaneseInputText: String = ""

    /// 右侧输入框（中文）
    var chineseInputText: String = ""

    /// 是否正在翻译
    var isLoading: Bool = false

    /// 错误提示
    var errorMessage: String?

    /// 当前对话（保存后）
    var currentConversation: Conversation?

    // MARK: - 依赖
    private let translationService: TranslationService
    private let modelContext: ModelContext

    // MARK: - 初始化
    init(modelContext: ModelContext, translationService: TranslationService = .shared) {
        self.modelContext = modelContext
        self.translationService = translationService
    }

    // MARK: - 计算属性
    var hasMessages: Bool {
        return !messages.isEmpty
    }

    var isJapaneseInputEmpty: Bool {
        return japaneseInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isChineseInputEmpty: Bool {
        return chineseInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - 发送日文消息（左侧输入 → 翻译成中文）
    func sendJapanese() async {
        guard !isJapaneseInputEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            let sourceText = japaneseInputText.trimmingCharacters(in: .whitespacesAndNewlines)
            let translatedText = try await translationService.translateJapaneseToChinese(sourceText)

            let message = Message(
                sourceText: sourceText,
                sourceLanguage: .japanese,
                translatedText: translatedText,
                targetLanguage: .chinese,
                isFromVoice: false
            )

            messages.append(message)
            japaneseInputText = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - 发送中文消息（右侧输入 → 翻译成日文）
    func sendChinese() async {
        guard !isChineseInputEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            let sourceText = chineseInputText.trimmingCharacters(in: .whitespacesAndNewlines)
            let translatedText = try await translationService.translateChineseToJapanese(sourceText)

            let message = Message(
                sourceText: sourceText,
                sourceLanguage: .chinese,
                translatedText: translatedText,
                targetLanguage: .japanese,
                isFromVoice: false
            )

            messages.append(message)
            chineseInputText = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - 保存对话
    func saveConversation() {
        guard hasMessages else { return }

        let conversation = Conversation(title: nil)
        for message in messages {
            conversation.addMessage(message)
        }

        modelContext.insert(conversation)

        do {
            try modelContext.save()
            currentConversation = conversation
            messages = []
        } catch {
            errorMessage = "保存失败：\(error.localizedDescription)"
        }
    }

    /// 删除单条消息
    func deleteMessage(_ message: Message) {
        messages.removeAll { $0.id == message.id }
    }

    /// 清空当前对话
    func clearConversation() {
        messages = []
        japaneseInputText = ""
        chineseInputText = ""
        currentConversation = nil
        errorMessage = nil
    }

    /// 清除错误提示
    func clearError() {
        errorMessage = nil
    }
}