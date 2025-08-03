//
//  PlayerViewController.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa
import Combine

class PlayerViewController: NSViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        setupQQMusicPlayerUI()
    }

    // 回调闭包 - 与主控制器通信
    var playPauseAction: (() -> Void)?
    var nextAction: (() -> Void)?
    var previousAction: (() -> Void)?
    var seekAction: ((TimeInterval) -> Void)?
    var volumeAction: ((Float) -> Void)?
    var repeatAction: (() -> Void)?
    var shuffleAction: (() -> Void)?
    
    // 当前播放状态
    private var isPlaying = false
    private var isRepeating = false
    private var isShuffling = false
    
    // 当前歌曲信息
    private var currentSong: Song?
    private var totalDuration: TimeInterval = 0
    
    // UI组件
    private let albumCoverView = NSImageView()
    private let songTitleLabel = NSTextField()
    private let artistLabel = NSTextField()
    private let playPauseButton = NSButton()
    private let previousButton = NSButton()
    private let nextButton = NSButton()
    private let progressSlider = NSSlider()
    private let timeLabel = NSTextField()
    private let durationLabel = NSTextField()
    private let repeatButton = NSButton()
    private let shuffleButton = NSButton()
    private let volumeSlider = NSSlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupButtons()
    }
    
    // 初始化视图组件 - Spotify 风格
    private func setupView() {
        view.wantsLayer = true
        // Spotify 播放器的深色背景
        view.layer?.backgroundColor = NSColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1).cgColor

        // 添加顶部分隔线
        let topBorder = NSView()
        topBorder.wantsLayer = true
        topBorder.layer?.backgroundColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBorder)

        // 专辑封面
        albumCoverView.wantsLayer = true
        albumCoverView.layer?.cornerRadius = 4
        albumCoverView.imageScaling = NSImageScaling.scaleAxesIndependently
        albumCoverView.clipsToBounds = true
        albumCoverView.translatesAutoresizingMaskIntoConstraints = false

        // 设置默认专辑封面
        if let defaultImage = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil) {
            albumCoverView.image = defaultImage
            albumCoverView.contentTintColor = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }

        view.addSubview(albumCoverView)

        // 设置约束
        NSLayoutConstraint.activate([
            // 顶部分隔线
            topBorder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBorder.topAnchor.constraint(equalTo: view.topAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 1),

            // 专辑封面
            albumCoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            albumCoverView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            albumCoverView.widthAnchor.constraint(equalToConstant: 56),
            albumCoverView.heightAnchor.constraint(equalToConstant: 56)
        ])

        // 设置歌曲信息区域
        setupSongInfoArea()

        // 设置播放控制区域
        setupPlaybackControls()

        // 设置音量控制区域
        setupVolumeControls()
    }

    private func setupSongInfoArea() {
        // 歌曲标题 - Spotify 风格
        songTitleLabel.isEditable = false
        songTitleLabel.isBordered = false
        songTitleLabel.backgroundColor = .clear
        songTitleLabel.textColor = NSColor.white
        songTitleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        songTitleLabel.lineBreakMode = .byTruncatingTail
        songTitleLabel.stringValue = "选择一首歌曲"
        songTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 艺术家名称 - Spotify 风格
        artistLabel.isEditable = false
        artistLabel.isBordered = false
        artistLabel.backgroundColor = .clear
        artistLabel.textColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        artistLabel.font = NSFont.systemFont(ofSize: 12)
        artistLabel.lineBreakMode = .byTruncatingTail
        artistLabel.stringValue = "ikugou"
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(songTitleLabel)
        view.addSubview(artistLabel)

        NSLayoutConstraint.activate([
            // 歌曲标题
            songTitleLabel.leadingAnchor.constraint(equalTo: albumCoverView.trailingAnchor, constant: 12),
            songTitleLabel.topAnchor.constraint(equalTo: albumCoverView.topAnchor, constant: 8),
            songTitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),

            // 艺术家名称
            artistLabel.leadingAnchor.constraint(equalTo: albumCoverView.trailingAnchor, constant: 12),
            artistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 2),
            artistLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
    }

    private func setupPlaybackControls() {
        // 设置播放控制按钮
        setupButtons()

        // 创建控制按钮容器
        let controlsContainer = NSView()
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsContainer)

        // 添加控制按钮
        controlsContainer.addSubview(shuffleButton)
        controlsContainer.addSubview(previousButton)
        controlsContainer.addSubview(playPauseButton)
        controlsContainer.addSubview(nextButton)
        controlsContainer.addSubview(repeatButton)

        // 设置按钮约束
        shuffleButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        repeatButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // 控制容器
            controlsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            controlsContainer.heightAnchor.constraint(equalToConstant: 40),
            controlsContainer.widthAnchor.constraint(equalToConstant: 240),

            // 随机播放按钮
            shuffleButton.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
            shuffleButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            shuffleButton.widthAnchor.constraint(equalToConstant: 32),
            shuffleButton.heightAnchor.constraint(equalToConstant: 32),

            // 上一曲按钮
            previousButton.leadingAnchor.constraint(equalTo: shuffleButton.trailingAnchor, constant: 16),
            previousButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            previousButton.widthAnchor.constraint(equalToConstant: 32),
            previousButton.heightAnchor.constraint(equalToConstant: 32),

            // 播放/暂停按钮
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainer.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),

            // 下一曲按钮
            nextButton.trailingAnchor.constraint(equalTo: repeatButton.leadingAnchor, constant: -16),
            nextButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 32),
            nextButton.heightAnchor.constraint(equalToConstant: 32),

            // 重复播放按钮
            repeatButton.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
            repeatButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            repeatButton.widthAnchor.constraint(equalToConstant: 32),
            repeatButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func setupVolumeControls() {
        // 音量图标
        let volumeIcon = NSImageView()
        volumeIcon.image = NSImage(systemSymbolName: "speaker.2.fill", accessibilityDescription: nil)
        volumeIcon.contentTintColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        volumeIcon.translatesAutoresizingMaskIntoConstraints = false

        // 音量滑块
        volumeSlider.minValue = 0
        volumeSlider.maxValue = 1
        volumeSlider.floatValue = 0.8
        volumeSlider.isContinuous = true
        volumeSlider.target = self
        volumeSlider.action = #selector(volumeSliderChanged(_:))
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(volumeIcon)
        view.addSubview(volumeSlider)

        NSLayoutConstraint.activate([
            // 音量图标
            volumeIcon.trailingAnchor.constraint(equalTo: volumeSlider.leadingAnchor, constant: -8),
            volumeIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            volumeIcon.widthAnchor.constraint(equalToConstant: 16),
            volumeIcon.heightAnchor.constraint(equalToConstant: 16),

            // 音量滑块
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            volumeSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            volumeSlider.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // 设置按钮样式和行为
    private func setupButtons() {
        // 播放/暂停按钮
        let playImage = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
        playPauseButton.image = playImage
        playPauseButton.bezelStyle = .texturedRounded
        playPauseButton.isBordered = false
        playPauseButton.target = self
        playPauseButton.action = #selector(playPauseTapped(_:))
        playPauseButton.setButtonType(.momentaryChange)
        
        // 上一曲按钮
        let previousImage = NSImage(systemSymbolName: "backward.fill", accessibilityDescription: nil)
        previousButton.image = previousImage
        previousButton.bezelStyle = .texturedRounded
        previousButton.isBordered = false
        previousButton.target = self
        previousButton.action = #selector(previousTapped(_:))
        
        // 下一曲按钮
        let nextImage = NSImage(systemSymbolName: "forward.fill", accessibilityDescription: nil)
        nextButton.image = nextImage
        nextButton.bezelStyle = .texturedRounded
        nextButton.isBordered = false
        nextButton.target = self
        nextButton.action = #selector(nextTapped(_:))
        
        // 重复按钮
        let repeatImage = NSImage(systemSymbolName: "repeat", accessibilityDescription: nil)
        repeatButton.image = repeatImage
        repeatButton.bezelStyle = .texturedRounded
        repeatButton.isBordered = false
        repeatButton.target = self
        repeatButton.action = #selector(repeatTapped(_:))
        
        // 随机播放按钮
        let shuffleImage = NSImage(systemSymbolName: "shuffle", accessibilityDescription: nil)
        shuffleButton.image = shuffleImage
        shuffleButton.bezelStyle = .texturedRounded
        shuffleButton.isBordered = false
        shuffleButton.target = self
        shuffleButton.action = #selector(shuffleTapped(_:))
        
        // 设置按钮图标颜色（macOS兼容方式）
        setupButtonColors()
    }
    
    // 为按钮设置白色图标（兼容不同macOS版本）
    private func setupButtonColors() {
        let buttons = [playPauseButton, previousButton, nextButton, repeatButton, shuffleButton]
        
        for button in buttons {
            button.image?.isTemplate = true
            
            if #available(macOS 10.14, *) {
                button.contentTintColor = .white
            } else {
                button.layer?.masksToBounds = false
                button.layer?.shadowColor = NSColor.white.cgColor
                button.layer?.shadowRadius = 0
                button.layer?.shadowOffset = .zero
                button.layer?.shadowOpacity = 1
            }
        }
    }
    
    // 设置界面布局约束
    private func setupLayout() {
        // 禁用 autoresizing mask
        [albumCoverView, songTitleLabel, artistLabel, playPauseButton,
         previousButton, nextButton, progressSlider, timeLabel, durationLabel,
         repeatButton, shuffleButton, volumeSlider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // 创建约束
        NSLayoutConstraint.activate([
            // 专辑封面
            albumCoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            albumCoverView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            albumCoverView.widthAnchor.constraint(equalToConstant: 60),
            albumCoverView.heightAnchor.constraint(equalToConstant: 60),
            
            // 歌曲标题
            songTitleLabel.leadingAnchor.constraint(equalTo: albumCoverView.trailingAnchor, constant: 12),
            songTitleLabel.topAnchor.constraint(equalTo: albumCoverView.topAnchor, constant: 8),
            songTitleLabel.widthAnchor.constraint(equalToConstant: 200),
            
            // 艺术家名称
            artistLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
            artistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 4),
            artistLabel.widthAnchor.constraint(equalTo: songTitleLabel.widthAnchor),
            
            // 重复按钮
            repeatButton.leadingAnchor.constraint(equalTo: artistLabel.trailingAnchor, constant: 20),
            repeatButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            repeatButton.widthAnchor.constraint(equalToConstant: 24),
            repeatButton.heightAnchor.constraint(equalToConstant: 24),
            
            // 上一曲按钮
            previousButton.leadingAnchor.constraint(equalTo: repeatButton.trailingAnchor, constant: 16),
            previousButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            previousButton.widthAnchor.constraint(equalToConstant: 28),
            previousButton.heightAnchor.constraint(equalToConstant: 28),
            
            // 播放/暂停按钮
            playPauseButton.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 16),
            playPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 36),
            playPauseButton.heightAnchor.constraint(equalToConstant: 36),
            
            // 下一曲按钮
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 16),
            nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 28),
            nextButton.heightAnchor.constraint(equalToConstant: 28),
            
            // 随机播放按钮
            shuffleButton.leadingAnchor.constraint(equalTo: nextButton.trailingAnchor, constant: 16),
            shuffleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            shuffleButton.widthAnchor.constraint(equalToConstant: 24),
            shuffleButton.heightAnchor.constraint(equalToConstant: 24),
            
            // 时间标签
            timeLabel.leadingAnchor.constraint(equalTo: shuffleButton.trailingAnchor, constant: 20),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 进度条
            progressSlider.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 8),
            progressSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -8),
            
            // 总时长标签
            durationLabel.trailingAnchor.constraint(equalTo: volumeSlider.leadingAnchor, constant: -16),
            durationLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 音量滑块
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            volumeSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            volumeSlider.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // 更新当前播放歌曲信息
    func update(with song: Song) {
        currentSong = song
        totalDuration = song.duration
        
        songTitleLabel.stringValue = song.name
        artistLabel.stringValue = song.artist
        durationLabel.stringValue = formatTime(song.duration)
        progressSlider.maxValue = Double(song.duration)
        progressSlider.floatValue = 0
        
        // 加载专辑封面
        if let url = URL(string: song.albumCoverUrl) {
            loadImage(from: url) { [weak self] image in
                self?.albumCoverView.image = image
            }
        }
    }
    
    // 更新播放/暂停状态
    func updatePlayPauseState(isPlaying: Bool) {
        self.isPlaying = isPlaying
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        let newImage = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        playPauseButton.image = newImage
    }
    
    // 更新重复状态
    func updateRepeatState(isRepeating: Bool) {
        self.isRepeating = isRepeating
        let imageName = isRepeating ? "repeat.fill" : "repeat"
        let newImage = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        repeatButton.image = newImage
        
        // 更新按钮颜色以反映状态
        if #available(macOS 10.14, *) {
            repeatButton.contentTintColor = isRepeating ? .systemGreen : .white
        }
    }
    
    // 更新随机播放状态
    func updateShuffleState(isShuffling: Bool) {
        self.isShuffling = isShuffling
        let imageName = isShuffling ? "shuffle.fill" : "shuffle"
        let newImage = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        shuffleButton.image = newImage
        
        // 更新按钮颜色以反映状态
        if #available(macOS 10.14, *) {
            shuffleButton.contentTintColor = isShuffling ? .systemGreen : .white
        }
    }
    
    // 更新播放进度
    func updateProgress(time: TimeInterval) {
        progressSlider.doubleValue = time
        timeLabel.stringValue = formatTime(time)
    }
    
    // 格式化时间（秒 -> mm:ss）
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time)/60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // 加载网络图片
    private func loadImage(from url: URL, completion: @escaping (NSImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = NSImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
    
    // 按钮点击事件处理
    @objc private func playPauseTapped(_ sender: NSButton) {
        playPauseAction?()
    }
    
    @objc private func previousTapped(_ sender: NSButton) {
        previousAction?()
    }
    
    @objc private func nextTapped(_ sender: NSButton) {
        nextAction?()
    }
    
    @objc private func repeatTapped(_ sender: NSButton) {
        isRepeating.toggle()
        updateRepeatState(isRepeating: isRepeating)
        repeatAction?()
    }
    
    @objc private func shuffleTapped(_ sender: NSButton) {
        isShuffling.toggle()
        updateShuffleState(isShuffling: isShuffling)
        shuffleAction?()
    }
    
    // 进度条变化事件
    @objc private func progressSliderChanged(_ sender: NSSlider) {
        seekAction?(TimeInterval(sender.floatValue))
    }
    
    // 音量滑块变化事件
    @objc private func volumeSliderChanged(_ sender: NSSlider) {
        volumeAction?(sender.floatValue)
    }

    // MARK: - QQ音乐风格播放器界面
    private func setupQQMusicPlayerUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor

        // QQ音乐绿色主题
        let qqGreen = NSColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1.0)

        // 专辑封面 - 圆角设计
        albumCoverView.wantsLayer = true
        albumCoverView.layer?.cornerRadius = 8
        albumCoverView.layer?.masksToBounds = true
        albumCoverView.imageScaling = .scaleProportionallyUpOrDown
        albumCoverView.translatesAutoresizingMaskIntoConstraints = false

        // 歌曲标题 - QQ音乐字体风格
        songTitleLabel.stringValue = "未播放"
        songTitleLabel.font = NSFont.boldSystemFont(ofSize: 14)
        songTitleLabel.textColor = .labelColor
        songTitleLabel.isEditable = false
        songTitleLabel.isBordered = false
        songTitleLabel.backgroundColor = .clear
        songTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 艺术家标签
        artistLabel.stringValue = ""
        artistLabel.font = NSFont.systemFont(ofSize: 12)
        artistLabel.textColor = .secondaryLabelColor
        artistLabel.isEditable = false
        artistLabel.isBordered = false
        artistLabel.backgroundColor = .clear
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        // 播放控制按钮 - QQ音乐风格
        setupQQMusicButtons(qqGreen: qqGreen)

        // 进度条 - QQ音乐绿色
        progressSlider.minValue = 0
        progressSlider.maxValue = 100
        progressSlider.doubleValue = 0
        progressSlider.target = self
        progressSlider.action = #selector(progressSliderChanged(_:))
        progressSlider.translatesAutoresizingMaskIntoConstraints = false

        // 时间标签
        let currentTimeLabel = NSTextField(labelWithString: "0:00")
        currentTimeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        currentTimeLabel.textColor = .secondaryLabelColor
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        let totalTimeLabel = NSTextField(labelWithString: "0:00")
        totalTimeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        totalTimeLabel.textColor = .secondaryLabelColor
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        // 音量控制
        volumeSlider.minValue = 0
        volumeSlider.maxValue = 1
        volumeSlider.doubleValue = 0.7
        volumeSlider.target = self
        volumeSlider.action = #selector(volumeSliderChanged(_:))
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false

        // 添加所有视图
        view.addSubview(albumCoverView)
        view.addSubview(songTitleLabel)
        view.addSubview(artistLabel)
        view.addSubview(previousButton)
        view.addSubview(playPauseButton)
        view.addSubview(nextButton)
        view.addSubview(currentTimeLabel)
        view.addSubview(progressSlider)
        view.addSubview(totalTimeLabel)
        view.addSubview(volumeSlider)

        // QQ音乐风格布局
        setupQQMusicLayout(currentTimeLabel: currentTimeLabel, totalTimeLabel: totalTimeLabel)
    }

    private func setupQQMusicButtons(qqGreen: NSColor) {
        // 上一首按钮
        previousButton.title = "⏮"
        previousButton.font = NSFont.systemFont(ofSize: 16)
        previousButton.bezelStyle = .circular
        previousButton.target = self
        previousButton.action = #selector(previousButtonClicked)
        previousButton.translatesAutoresizingMaskIntoConstraints = false

        // 播放/暂停按钮 - QQ音乐风格
        playPauseButton.title = "▶️"
        playPauseButton.font = NSFont.systemFont(ofSize: 18)
        playPauseButton.bezelStyle = .circular
        playPauseButton.contentTintColor = qqGreen
        playPauseButton.target = self
        playPauseButton.action = #selector(playPauseButtonClicked)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false

        // 下一首按钮
        nextButton.title = "⏭"
        nextButton.font = NSFont.systemFont(ofSize: 16)
        nextButton.bezelStyle = .circular
        nextButton.target = self
        nextButton.action = #selector(nextButtonClicked)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupQQMusicLayout(currentTimeLabel: NSTextField, totalTimeLabel: NSTextField) {
        NSLayoutConstraint.activate([
            // 专辑封面 - 左侧
            albumCoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            albumCoverView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            albumCoverView.widthAnchor.constraint(equalToConstant: 50),
            albumCoverView.heightAnchor.constraint(equalToConstant: 50),

            // 歌曲信息 - 专辑封面右侧
            songTitleLabel.leadingAnchor.constraint(equalTo: albumCoverView.trailingAnchor, constant: 12),
            songTitleLabel.topAnchor.constraint(equalTo: albumCoverView.topAnchor, constant: 8),
            songTitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),

            artistLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
            artistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 4),
            artistLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),

            // 播放控制按钮 - 中央
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),

            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -12),
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousButton.widthAnchor.constraint(equalToConstant: 32),
            previousButton.heightAnchor.constraint(equalToConstant: 32),

            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 12),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 32),
            nextButton.heightAnchor.constraint(equalToConstant: 32),

            // 进度条和时间 - 底部
            currentTimeLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
            currentTimeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 8),
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            progressSlider.trailingAnchor.constraint(equalTo: totalTimeLabel.leadingAnchor, constant: -8),

            totalTimeLabel.trailingAnchor.constraint(equalTo: volumeSlider.leadingAnchor, constant: -16),
            totalTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),

            // 音量控制 - 右侧
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            volumeSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            volumeSlider.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - 按钮点击事件
    @objc private func playPauseButtonClicked() {
        isPlaying.toggle()
        playPauseButton.title = isPlaying ? "⏸" : "▶️"
        playPauseAction?()
    }

    @objc private func previousButtonClicked() {
        previousAction?()
    }

    @objc private func nextButtonClicked() {
        nextAction?()
    }
}

