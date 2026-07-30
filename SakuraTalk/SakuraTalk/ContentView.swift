import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            ConversationView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                }

            CameraView()
                .tabItem {
                    Image(systemName: "camera")
                }
        }
        .tint(.black)
    }
}

// MARK: - 对话视图（双人输入模式）
struct ConversationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ConversationViewModel?
    @State private var showHistory = false
    @State private var activeMenuMessage: Message?
    @FocusState private var focusedField: InputField?

    enum InputField {
        case japanese, chinese
    }

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    chatContent(vm)
                } else {
                    Color.white
                        .onAppear {
                            viewModel = ConversationViewModel(modelContext: modelContext)
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("对话")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                }

                ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                showHistory = true
                            } label: {
                                Label("历史对话", systemImage: "clock")
                            }

                            if let vm = viewModel, vm.hasMessages {
                                Divider()

                                Button {
                                    vm.saveConversation()
                                } label: {
                                    Label("保存对话", systemImage: "square.and.arrow.down")
                                }

                                Button(role: .destructive) {
                                    vm.clearConversation()
                                } label: {
                                    Label("清空对话", systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.black.opacity(0.6))
                        }
                    }
            }
        }
    }

    // MARK: - 聊天主界面
    @ViewBuilder
    private func chatContent(_ vm: ConversationViewModel) -> some View {
        VStack(spacing: 0) {
            // 消息列表（占满剩余空间）
            ScrollViewReader { proxy in
                ScrollView {
                    if vm.messages.isEmpty {
                        // 空状态 - 居中显示
                        emptyStateView
                            .frame(minHeight: 300)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                                    .overlay(alignment: .top) {
                                        if message.id == activeMenuMessage?.id {
                                            BubbleFloatingMenu(
                                                onCopy: {
                                                    UIPasteboard.general.string = message.sourceText
                                                    activeMenuMessage = nil
                                                },
                                                onDelete: {
                                                    vm.deleteMessage(message)
                                                    activeMenuMessage = nil
                                                }
                                            )
                                            .offset(y: -40)
                                            .transition(.scale(scale: 0.8, anchor: .bottom).combined(with: .opacity))
                                        }
                                    }
                                    .onLongPressGesture {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                            activeMenuMessage = message
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
                .frame(maxHeight: .infinity)
                .scrollDismissesKeyboard(.immediately)
                .onTapGesture {
                    focusedField = nil
                    withAnimation(.easeOut(duration: 0.15)) {
                        activeMenuMessage = nil
                    }
                }
                .onChange(of: vm.messages.count) {
                    if let lastMessage = vm.messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // 分隔线
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 0.5)

            // 底部双人输入栏（紧凑）
            dualInputBar(vm)
                .fixedSize(horizontal: false, vertical: true)
        }
        .background(Color(hex: "F5F5F5"))
        .overlay {
            if vm.isLoading {
                LoadingOverlay(message: "正在翻译...")
            }
        }
        .alert("提示", isPresented: .init(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.clearError() } }
        )) {
            Button("确定") { vm.clearError() }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
    }

    // MARK: - 复制消息（复制原语言）
    private func copyMessage(_ message: Message) {
        UIPasteboard.general.string = message.sourceText
    }

    // MARK: - 空状态
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.black.opacity(0.12))

            VStack(spacing: 6) {
                Text("开始对话")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.black.opacity(0.5))

                Text("左边输入日文，右边输入中文")
                    .font(.system(size: 13))
                    .foregroundStyle(.black.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 双人输入栏
    private func dualInputBar(_ vm: ConversationViewModel) -> some View {
        HStack(spacing: 0) {
            // 左侧 - 日文输入
            japaneseInputPanel(vm: vm)

            // 中间分隔线
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(width: 0.5)

            // 右侧 - 中文输入
            chineseInputPanel(vm: vm)
        }
        .background(.white)
    }

    // MARK: - 日文输入面板（左侧）
    private func japaneseInputPanel(vm: ConversationViewModel) -> some View {
        @Bindable var bindableVM = vm
        return HStack(alignment: .bottom, spacing: 8) {
            // 话筒
            Button {
                // TODO: 语音输入
            } label: {
                Image(systemName: "mic")
                    .font(.system(size: 18))
                    .foregroundStyle(.black.opacity(0.4))
                    .frame(width: 32, height: 32)
            }

            // 输入框（随内容自动扩展，最多5行）
            TextField("日本語を入力", text: $bindableVM.japaneseInputText, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(1...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(hex: "F5F5F5"))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .focused($focusedField, equals: .japanese)
                .autocorrectionDisabled()

            // 发送按钮
            if !vm.isJapaneseInputEmpty {
                Button {
                    focusedField = nil
                    Task { await vm.sendJapanese() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.black)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .animation(.easeInOut(duration: 0.2), value: vm.isJapaneseInputEmpty)
    }

    // MARK: - 中文输入面板（右侧）
    private func chineseInputPanel(vm: ConversationViewModel) -> some View {
        @Bindable var bindableVM = vm
        return HStack(alignment: .bottom, spacing: 8) {
            // 发送按钮
            if !vm.isChineseInputEmpty {
                Button {
                    focusedField = nil
                    Task { await vm.sendChinese() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.black)
                }
                .transition(.scale.combined(with: .opacity))
            }

            // 输入框（随内容自动扩展，最多5行）
            TextField("输入中文", text: $bindableVM.chineseInputText, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(1...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(hex: "F5F5F5"))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .focused($focusedField, equals: .chinese)
                .autocorrectionDisabled()

            // 话筒
            Button {
                // TODO: 语音输入
            } label: {
                Image(systemName: "mic")
                    .font(.system(size: 18))
                    .foregroundStyle(.black.opacity(0.4))
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .animation(.easeInOut(duration: 0.2), value: vm.isChineseInputEmpty)
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
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var allConversations: [Conversation]
    @Query(sort: \PhotoTranslation.createdAt, order: .reverse) private var allPhotoTranslations: [PhotoTranslation]
    @State private var selectedTab = 0 // 0: 对话, 1: 拍照
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker = false

    // 筛选后的数据
    private var conversations: [Conversation] {
        if let date = selectedDate {
            let calendar = Calendar.current
            return allConversations.filter { calendar.isDate($0.updatedAt, inSameDayAs: date) }
        }
        return allConversations
    }

    private var photoTranslations: [PhotoTranslation] {
        if let date = selectedDate {
            let calendar = Calendar.current
            return allPhotoTranslations.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
        }
        return allPhotoTranslations
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部分段控制器
                Picker("记录类型", selection: $selectedTab) {
                    Text("对话记录").tag(0)
                    Text("拍照翻译").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.top, 12)

                // 日期筛选器
                HStack(spacing: 12) {
                    // 全部按钮
                    Button {
                        selectedDate = nil
                    } label: {
                        Text("全部")
                            .font(.system(size: 15, weight: selectedDate == nil ? .medium : .regular))
                            .foregroundStyle(selectedDate == nil ? .white : .black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedDate == nil ? Color.black : Color.black.opacity(0.05))
                            )
                    }

                    // 日历选择器按钮
                    Button {
                        showDatePicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                            Text(selectedDate != nil ? formatDate(selectedDate!) : "选择日期")
                                .font(.system(size: 15))
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedDate != nil ? Color.black.opacity(0.1) : Color.black.opacity(0.05))
                        )
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)

                // 记录列表
                if selectedTab == 0 {
                    ConversationListView(
                        conversations: conversations,
                        onDelete: { conversation in
                            deleteConversation(conversation)
                        },
                        onClearAll: {
                            clearAllConversations()
                        },
                        onToggleFavorite: { conversation in
                            toggleConversationFavorite(conversation)
                        }
                    )
                } else {
                    PhotoTranslationListView(
                        photoTranslations: photoTranslations,
                        onDelete: { photoTranslation in
                            deletePhotoTranslation(photoTranslation)
                        },
                        onClearAll: {
                            clearAllPhotoTranslations()
                        },
                        onToggleFavorite: { photoTranslation in
                            toggleFavorite(photoTranslation)
                        }
                    )
                }
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

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            addSampleData()
                        } label: {
                            Label("添加示例数据", systemImage: "plus")
                        }

                        Divider()

                        if selectedTab == 0 && !conversations.isEmpty {
                            Button(role: .destructive) {
                                clearAllConversations()
                            } label: {
                                Label("清空所有对话", systemImage: "trash")
                            }
                        } else if selectedTab == 1 && !photoTranslations.isEmpty {
                            Button(role: .destructive) {
                                clearAllPhotoTranslations()
                            } label: {
                                Label("清空所有翻译", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.black.opacity(0.6))
                    }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                MinimalDatePicker(selectedDate: $selectedDate, showDatePicker: $showDatePicker)
                    .presentationDetents([.height(400)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        return formatter.string(from: date)
    }

    // MARK: - 数据操作
    private func deleteConversation(_ conversation: Conversation) {
        modelContext.delete(conversation)
        try? modelContext.save()
    }

    private func deletePhotoTranslation(_ photoTranslation: PhotoTranslation) {
        modelContext.delete(photoTranslation)
        try? modelContext.save()
    }

    private func clearAllConversations() {
        for conversation in conversations {
            modelContext.delete(conversation)
        }
        try? modelContext.save()
    }

    private func clearAllPhotoTranslations() {
        for photoTranslation in photoTranslations {
            modelContext.delete(photoTranslation)
        }
        try? modelContext.save()
    }

    private func toggleFavorite(_ photoTranslation: PhotoTranslation) {
        photoTranslation.isFavorite.toggle()
        try? modelContext.save()
    }

    private func toggleConversationFavorite(_ conversation: Conversation) {
        conversation.isFavorite.toggle()
        try? modelContext.save()
    }

    // MARK: - 添加示例数据
    private func addSampleData() {
        // 示例对话 1：餐厅点餐
        let conversation1 = Conversation(title: "在餐厅点餐")
        conversation1.addMessage(Message(
            sourceText: "すみません、メニューをお願いします",
            sourceLanguage: .japanese,
            translatedText: "不好意思，请给我菜单",
            targetLanguage: .chinese,
            isFromVoice: true
        ))
        conversation1.addMessage(Message(
            sourceText: "好的，这是菜单。有什么推荐的吗？",
            sourceLanguage: .chinese,
            translatedText: "はい、メニューです。おすすめは何ですか？",
            targetLanguage: .japanese
        ))
        conversation1.addMessage(Message(
            sourceText: "季節のランチセットがおすすめです",
            sourceLanguage: .japanese,
            translatedText: "推荐季节性午餐套餐",
            targetLanguage: .chinese
        ))
        modelContext.insert(conversation1)

        // 示例对话 2：问路（已收藏）
        let conversation2 = Conversation(title: "在车站问路")
        conversation2.addMessage(Message(
            sourceText: "请问，去东京塔怎么走？",
            sourceLanguage: .chinese,
            translatedText: "すみません、東京タワーへはどう行けばいいですか？",
            targetLanguage: .japanese
        ))
        conversation2.addMessage(Message(
            sourceText: "この道をまっすぐ行って、次の交差点を右に曲がってください",
            sourceLanguage: .japanese,
            translatedText: "沿着这条路直走，在下一个十字路口右转",
            targetLanguage: .chinese
        ))
        conversation2.isFavorite = true
        modelContext.insert(conversation2)

        // 示例拍照翻译 1
        let photo1 = PhotoTranslation(
            imageData: nil,
            recognizedText: "ラーメン（味玉入）\n醤油スープ\n￥850",
            translatedText: "拉面（加味玉）\n酱油汤底\n￥850",
            note: "拉面店的菜单"
        )
        photo1.isFavorite = true
        modelContext.insert(photo1)

        // 示例拍照翻译 2
        let photo2 = PhotoTranslation(
            imageData: nil,
            recognizedText: "駅前通り\n東西線\n渋谷方面",
            translatedText: "站前大道\n东西线\n涩谷方向",
            note: "车站指示牌"
        )
        modelContext.insert(photo2)

        // 示例拍照翻译 3
        let photo3 = PhotoTranslation(
            imageData: nil,
            recognizedText: "お惣菜コーナー\nから揚げ 3個入\n税込￥398",
            translatedText: "熟食区\n炸鸡 3个装\n含税￥398",
            note: nil
        )
        modelContext.insert(photo3)

        try? modelContext.save()
        print("✅ 示例数据添加成功")
    }
}

// MARK: - 简约日历选择器
struct MinimalDatePicker: View {
    @Binding var selectedDate: Date?
    @Binding var showDatePicker: Bool
    @State private var displayedMonth: Date = Date()

    private let daysOfWeek = ["日", "一", "二", "三", "四", "五", "六"]
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            // 月份导航
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black)
                }

                Spacer()

                Text(monthYearString)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            // 星期标题
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.black.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            // 日历网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!),
                            isToday: calendar.isDateInToday(date)
                        ) {
                            selectedDate = date
                            showDatePicker = false
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            // 清除选择按钮
            Button {
                selectedDate = nil
                showDatePicker = false
            } label: {
                Text("显示全部")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black.opacity(0.6))
            }
            .padding(.bottom, 16)
        }
        .background(.white)
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        return formatter.string(from: displayedMonth)
    }

    private var daysInMonth: [Date?] {
        let interval = calendar.dateInterval(of: .month, for: displayedMonth)!
        let firstDate = interval.start
        let lastDate = interval.end

        var days: [Date?] = []

        // 添加前导空白
        let firstWeekday = calendar.component(.weekday, from: firstDate)
        let leadingEmptyDays = (firstWeekday - 1) % 7
        days.append(contentsOf: Array(repeating: nil, count: leadingEmptyDays))

        // 添加日期
        var currentDate = firstDate
        while currentDate < lastDate {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return days
    }

    private func changeMonth(by value: Int) {
        displayedMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
    }
}

// MARK: - 日历单元格
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 36, height: 36)
                } else if isToday {
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 36, height: 36)
                }

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .black)
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 对话记录列表
struct ConversationListView: View {
    let conversations: [Conversation]
    let onDelete: (Conversation) -> Void
    let onClearAll: () -> Void
    let onToggleFavorite: (Conversation) -> Void

    var body: some View {
        if conversations.isEmpty {
            EmptyStateView(
                icon: "bubble.left.and.bubble.right",
                title: "暂无对话记录",
                subtitle: "使用对话翻译后，记录会保存在这里"
            )
        } else {
            List {
                ForEach(conversations) { conversation in
                    ConversationRowView(conversation: conversation)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // 删除按钮
                            Button(role: .destructive) {
                                onDelete(conversation)
                            } label: {
                                Image(systemName: "trash")
                            }

                            // 收藏按钮
                            Button {
                                onToggleFavorite(conversation)
                            } label: {
                                Image(systemName: conversation.isFavorite ? "heart.slash" : "heart")
                            }
                            .tint(.black)
                        }
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: Conversation.self) { conversation in
                ConversationDetailView(conversation: conversation)
            }
        }
    }
}

// MARK: - 对话行视图
struct ConversationRowView: View {
    let conversation: Conversation

    var body: some View {
        NavigationLink(value: conversation) {
            HStack(spacing: 0) {
                // 时间轴左侧
                VStack(spacing: 0) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)

                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 1)
                }
                .frame(width: 20)
                .padding(.top, 4)

                // 时间标签（卡片上方）
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatTime(conversation.updatedAt))
                        .font(.system(size: 11))
                        .foregroundStyle(.black.opacity(0.4))

                    // 内容卡片
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(conversation.displayTitle)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.black)

                            Spacer()

                            if conversation.isFavorite {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.black)
                            }
                        }

                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 12))
                                .foregroundStyle(.black.opacity(0.3))

                            Text("\(conversation.messageCount) 条消息")
                                .font(.system(size: 14))
                                .foregroundStyle(.black.opacity(0.5))
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.02))
                    )
                }
                .padding(.leading, 12)
            }
        }
        .buttonStyle(.plain)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        return formatter.string(from: date)
    }
}

// MARK: - 拍照翻译列表
struct PhotoTranslationListView: View {
    let photoTranslations: [PhotoTranslation]
    let onDelete: (PhotoTranslation) -> Void
    let onClearAll: () -> Void
    let onToggleFavorite: (PhotoTranslation) -> Void

    var body: some View {
        if photoTranslations.isEmpty {
            EmptyStateView(
                icon: "camera",
                title: "暂无拍照翻译",
                subtitle: "使用拍照翻译后，记录会保存在这里"
            )
        } else {
            List {
                ForEach(photoTranslations) { photoTranslation in
                    PhotoTranslationRowView(photoTranslation: photoTranslation)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // 删除按钮
                            Button(role: .destructive) {
                                onDelete(photoTranslation)
                            } label: {
                                Image(systemName: "trash")
                            }

                            // 收藏按钮
                            Button {
                                onToggleFavorite(photoTranslation)
                            } label: {
                                Image(systemName: photoTranslation.isFavorite ? "heart.slash" : "heart")
                            }
                            .tint(.black)
                        }
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: PhotoTranslation.self) { photoTranslation in
                PhotoTranslationDetailView(photoTranslation: photoTranslation)
            }
        }
    }
}

// MARK: - 拍照翻译行视图
struct PhotoTranslationRowView: View {
    let photoTranslation: PhotoTranslation

    var body: some View {
        NavigationLink(value: photoTranslation) {
            HStack(spacing: 0) {
                // 时间轴左侧
                VStack(spacing: 0) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)

                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 1)
                }
                .frame(width: 20)
                .padding(.top, 4)

                // 时间标签（卡片上方）
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatTime(photoTranslation.createdAt))
                        .font(.system(size: 11))
                        .foregroundStyle(.black.opacity(0.4))

                    // 内容卡片
                    HStack(spacing: 12) {
                        // 缩略图
                        Group {
                            if let imageData = photoTranslation.imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.black.opacity(0.05))
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.black.opacity(0.2))
                                    }
                            }
                        }

                        // 文本信息
                        HStack {
                            Text(photoTranslation.textPreview)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.black)
                                .lineLimit(2)

                            Spacer()

                            if photoTranslation.isFavorite {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.black)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.02))
                    )
                }
                .padding(.leading, 12)
            }
        }
        .buttonStyle(.plain)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        return formatter.string(from: date)
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.black.opacity(0.2))

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.black)

                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(.black.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 气泡悬浮菜单（小红书风格）
struct BubbleFloatingMenu: View {
    let onCopy: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // 复制
            Button(action: onCopy) {
                HStack(spacing: 5) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 13))
                    Text("复制")
                        .font(.system(size: 14))
                        .fixedSize()
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
            }

            // 分隔线
            Rectangle()
                .fill(Color.white.opacity(0.25))
                .frame(width: 0.5, height: 16)

            // 删除
            Button(action: onDelete) {
                HStack(spacing: 5) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                    Text("删除")
                        .font(.system(size: 14))
                        .fixedSize()
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
            }
        }
        .background(
            Capsule()
                .fill(Color.black.opacity(0.85))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
    }
}

#Preview {
    ContentView()
}