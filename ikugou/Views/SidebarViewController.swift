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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        loadData()
    }
    
    private func setupView() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    private func setupTableView() {
        // 配置表格视图
        tableView.delegate = self
        tableView.dataSource = self
        if #available(macOS 11.0, *) {
            tableView.style = .sourceList
        } else {
            tableView.selectionHighlightStyle = .sourceList
        }
        tableView.backgroundColor = .clear
        tableView.intercellSpacing = NSSize(width: 0, height: 2)
        tableView.allowsMultipleSelection = false
        tableView.headerView = nil
        
        // 添加表格列
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("SidebarColumn"))
        tableView.addTableColumn(column)
        
        // 关键修改：完全移除register方法调用
        
        // 添加到滚动视图
        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        // 完全手动创建单元格，不依赖任何注册机制
        let cell = SidebarCell()
        cell.identifier = cellIdentifier
        
        let item = items[row]
        cell.configure(with: item, symbolName: item.imageName)
        let isSelected = tableView.selectedRowIndexes.contains(row)
        cell.setSelected(isSelected, symbolName: item.imageName)
        
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
    private var normalIconColor: NSColor = .systemGray
    private var selectedIconColor: NSColor = .systemBlue
    
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
        
        // 配置选中背景
        selectionBackgroundLayer = CALayer()
        selectionBackgroundLayer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.2).cgColor
        selectionBackgroundLayer?.isHidden = true
        
        if let layer = self.layer, let bgLayer = selectionBackgroundLayer {
            layer.insertSublayer(bgLayer, at: 0)
        }
        
        // 配置图标视图
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = NSImageScaling.scaleAxesIndependently
        
        // 配置标题标签
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        
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
        selectionBackgroundLayer?.frame = bounds
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
        titleLabel.textColor = selected ? selectedIconColor : .white
        
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
    
    
    
    
    
    
