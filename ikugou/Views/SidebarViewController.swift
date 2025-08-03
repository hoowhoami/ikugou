//
//  SidebarViewController.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa

// 侧边栏项目类型
enum SidebarItemType {
    case home
    case search
    case yourLibrary
    case playlist(id: String)
}

// 侧边栏项目模型
struct SidebarItem {
    let id: String
    let title: String
    let imageName: String
    let type: SidebarItemType
}

// 侧边栏代理协议
protocol SidebarViewControllerDelegate: AnyObject {
    func sidebarDidSelectItem(_ item: SidebarItem)
}

class SidebarViewController: NSViewController {
    weak var delegate: SidebarViewControllerDelegate?

    private let tableView = NSTableView()
    private var items: [SidebarItem] = []
    private let cellIdentifier = NSUserInterfaceItemIdentifier("SidebarCell")

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSidebarContent()
        print("🔧 SidebarViewController viewDidLoad 完成")
    }

    private func setupView() {
        view.wantsLayer = true
        // QQ音乐风格的侧边栏背景色
        view.layer?.backgroundColor = NSColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1).cgColor
    }

    private func setupSidebarContent() {
        // 创建主要导航项目 - QQ音乐风格
        let homeItem = createNavigationItem(title: "首页", icon: "house.fill", isSelected: true)
        let discoverItem = createNavigationItem(title: "发现", icon: "sparkles")

        // 我的音乐分组
        let myMusicLabel = NSTextField(labelWithString: "我的音乐")
        myMusicLabel.textColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        myMusicLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        myMusicLabel.translatesAutoresizingMaskIntoConstraints = false

        let likeItem = createNavigationItem(title: "喜欢", icon: "heart.fill", count: "165")
        let recentItem = createNavigationItem(title: "最近", icon: "clock.fill", count: "419")
        let localItem = createNavigationItem(title: "本地", icon: "folder.fill")

        // 创建的歌单分组
        let playlistLabel = NSTextField(labelWithString: "创建的歌单")
        playlistLabel.textColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        playlistLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        playlistLabel.translatesAutoresizingMaskIntoConstraints = false

        // 添加按钮
        let addButton = NSButton()
        addButton.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
        addButton.bezelStyle = .regularSquare
        addButton.isBordered = false
        addButton.contentTintColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        // QQ音乐歌单
        let qqMusicItem = createPlaylistItem(title: "QQ音乐", image: "music.note")

        // 添加到视图
        view.addSubview(homeItem)
        view.addSubview(discoverItem)
        view.addSubview(myMusicLabel)
        view.addSubview(likeItem)
        view.addSubview(recentItem)
        view.addSubview(localItem)
        view.addSubview(playlistLabel)
        view.addSubview(addButton)
        view.addSubview(qqMusicItem)

        // 设置约束
        NSLayoutConstraint.activate([
            // 首页
            homeItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            homeItem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            homeItem.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            homeItem.heightAnchor.constraint(equalToConstant: 36),

            // 发现
            discoverItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            discoverItem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            discoverItem.topAnchor.constraint(equalTo: homeItem.bottomAnchor, constant: 4),
            discoverItem.heightAnchor.constraint(equalToConstant: 36),

            // 我的音乐标题
            myMusicLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myMusicLabel.topAnchor.constraint(equalTo: discoverItem.bottomAnchor, constant: 20),

            // 喜欢
            likeItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            likeItem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            likeItem.topAnchor.constraint(equalTo: myMusicLabel.bottomAnchor, constant: 8),
            likeItem.heightAnchor.constraint(equalToConstant: 36),

            // 最近
            recentItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            recentItem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            recentItem.topAnchor.constraint(equalTo: likeItem.bottomAnchor, constant: 4),
            recentItem.heightAnchor.constraint(equalToConstant: 36),

            // 本地
            localItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            localItem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            localItem.topAnchor.constraint(equalTo: recentItem.bottomAnchor, constant: 4),
            localItem.heightAnchor.constraint(equalToConstant: 36),

            // 创建的歌单标题
            playlistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playlistLabel.topAnchor.constraint(equalTo: localItem.bottomAnchor, constant: 20),

            // 添加按钮
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: playlistLabel.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 16),
            addButton.heightAnchor.constraint(equalToConstant: 16),

            // QQ音乐歌单
            qqMusicItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            qqMusicItem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            qqMusicItem.topAnchor.constraint(equalTo: playlistLabel.bottomAnchor, constant: 8),
            qqMusicItem.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func createNavigationItem(title: String, icon: String, isSelected: Bool = false, count: String? = nil) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.translatesAutoresizingMaskIntoConstraints = false

        // 设置背景色 - QQ音乐风格
        if isSelected {
            container.layer?.backgroundColor = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 0.1).cgColor
            container.layer?.cornerRadius = 6
        }

        // 图标
        let iconView = NSImageView()
        iconView.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        iconView.contentTintColor = isSelected ? NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1) : NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        // 标题
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.textColor = isSelected ? NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1) : NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: isSelected ? .medium : .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(titleLabel)

        var constraints = [
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ]

        // 如果有计数，添加计数标签
        if let count = count {
            let countLabel = NSTextField(labelWithString: count)
            countLabel.textColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            countLabel.font = NSFont.systemFont(ofSize: 11)
            countLabel.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(countLabel)

            constraints.append(contentsOf: [
                countLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -8)
            ])
        } else {
            constraints.append(titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16))
        }

        NSLayoutConstraint.activate(constraints)

        return container
    }

    private func createPlaylistItem(title: String, image: String) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.translatesAutoresizingMaskIntoConstraints = false

        // 专辑封面
        let albumView = NSImageView()
        albumView.image = NSImage(systemSymbolName: image, accessibilityDescription: nil)
        albumView.contentTintColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        albumView.wantsLayer = true
        albumView.layer?.cornerRadius = 4
        albumView.translatesAutoresizingMaskIntoConstraints = false

        // 标题
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.textColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        titleLabel.font = NSFont.systemFont(ofSize: 13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(albumView)
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            albumView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            albumView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            albumView.widthAnchor.constraint(equalToConstant: 24),
            albumView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: albumView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16)
        ])

        return container
    }

    private func setupTableView() {
        // 配置表格视图 - Spotify 风格
        tableView.delegate = self
        tableView.dataSource = self
        if #available(macOS 11.0, *) {
            tableView.style = .plain // 使用 plain 样式而不是 sourceList
        } else {
            tableView.selectionHighlightStyle = .regular
        }
        tableView.backgroundColor = .clear
        tableView.intercellSpacing = NSSize(width: 0, height: 4) // 增加行间距
        tableView.allowsMultipleSelection = false
        tableView.headerView = nil
        tableView.rowHeight = 40 // 设置固定行高
        
        // 添加表格列
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("SidebarColumn"))
        tableView.addTableColumn(column)
        
        // 关键修改：完全移除register方法调用
        
        // 创建顶部 logo 区域
        let logoContainer = NSView()
        logoContainer.wantsLayer = true
        logoContainer.translatesAutoresizingMaskIntoConstraints = false

        let logoLabel = NSTextField(labelWithString: "ikugou")
        logoLabel.font = NSFont.boldSystemFont(ofSize: 24)
        logoLabel.textColor = NSColor.white
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.addSubview(logoLabel)

        // 添加到滚动视图
        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoContainer)
        view.addSubview(scrollView)

        // 设置约束
        NSLayoutConstraint.activate([
            // Logo 容器约束
            logoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logoContainer.topAnchor.constraint(equalTo: view.topAnchor),
            logoContainer.heightAnchor.constraint(equalToConstant: 60),

            // Logo 标签约束
            logoLabel.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),

            // 滚动视图约束
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            scrollView.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 8),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }

    // 简化版本的表格视图设置
    private func setupSimpleTableView() {
        // 配置表格视图 - 最简化版本
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.allowsMultipleSelection = false
        tableView.headerView = nil
        tableView.rowHeight = 40

        // 添加表格列
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("SidebarColumn"))
        tableView.addTableColumn(column)

        // 直接添加表格视图，不使用滚动视图
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // 最简化的约束设置
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // 加载侧边栏数据
    func loadData() {
        items = [
            SidebarItem(id: "home", title: "首页", imageName: "house.fill", type: .home),
            SidebarItem(id: "search", title: "搜索", imageName: "magnifyingglass", type: .search),
            SidebarItem(id: "library", title: "你的媒体库", imageName: "music.note.list", type: .yourLibrary),
            SidebarItem(id: "playlist1", title: "我的喜爱", imageName: "music.note", type: .playlist(id: "1")),
            SidebarItem(id: "playlist2", title: "工作音乐", imageName: "music.note", type: .playlist(id: "2")),
            SidebarItem(id: "playlist3", title: "健身必备", imageName: "music.note", type: .playlist(id: "3"))
        ]
        
        tableView.reloadData()
        tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }
}

// 表格视图数据源和代理
extension SidebarViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // 创建简单的文本单元格
        let cell = NSTableCellView()
        cell.identifier = cellIdentifier

        let textField = NSTextField()
        textField.isEditable = false
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.stringValue = items[row].title
        textField.translatesAutoresizingMaskIntoConstraints = false

        cell.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16)
        ])

        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView,
              let selectedRow = tableView.selectedRowIndexes.first,
              selectedRow < items.count else {
            return
        }
        
        let selectedItem = items[selectedRow]
        delegate?.sidebarDidSelectItem(selectedItem)
        tableView.reloadData(forRowIndexes: IndexSet(integer: selectedRow), columnIndexes: IndexSet(integer: 0))
    }
}

// 侧边栏自定义单元格（纯代码实现）
class SidebarCell: NSTableCellView {
    // 纯代码创建视图
    let iconView = NSImageView()
    let titleLabel = NSTextField()
    
    private var selectionBackgroundLayer: CALayer?
    private var normalIconColor: NSColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1) // Spotify 风格的灰色
    private var selectedIconColor: NSColor = NSColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1) // Spotify 绿色
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        wantsLayer = true
        
        // 配置选中背景 - Spotify 风格
        selectionBackgroundLayer = CALayer()
        selectionBackgroundLayer?.backgroundColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1).cgColor
        selectionBackgroundLayer?.cornerRadius = 4
        selectionBackgroundLayer?.isHidden = true
        
        if let layer = self.layer, let bgLayer = selectionBackgroundLayer {
            layer.insertSublayer(bgLayer, at: 0)
        }
        
        // 配置图标视图
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = NSImageScaling.scaleAxesIndependently
        
        // 配置标题标签 - Spotify 风格
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        
        // 添加子视图
        addSubview(iconView)
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 图标约束
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            // 标题约束
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    override func layout() {
        super.layout()
        // 为选中背景添加边距，更像 Spotify
        let inset: CGFloat = 8
        selectionBackgroundLayer?.frame = bounds.insetBy(dx: inset, dy: 2)
    }
    
    func configure(with item: SidebarItem, symbolName: String) {
        titleLabel.stringValue = item.title
        
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
            let tintedImage = image.tinted(with: normalIconColor)
            iconView.image = tintedImage
        }
    }
    
    func setSelected(_ selected: Bool, symbolName: String) {
        selectionBackgroundLayer?.isHidden = !selected
        titleLabel.textColor = selected ? NSColor.white : NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
            let tintColor = selected ? selectedIconColor : normalIconColor
            let tintedImage = image.tinted(with: tintColor)
            iconView.image = tintedImage
        }
    }
}

// 为NSImage添加着色扩展方法
extension NSImage {
    func tinted(with color: NSColor) -> NSImage? {
        let tintedImage = NSImage(size: size, flipped: false) { rect in
            self.draw(in: rect)
            color.set()
            rect.fill(using: .sourceAtop)
            return true
        }
        return tintedImage
    }
}
    
    
    
    
    
    
