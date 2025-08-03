//
//  PlayerViewController.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Cocoa
import Combine

class PlayerViewController: NSViewController {
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
    
    // 初始化视图组件
    private func setupView() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1).cgColor
        
        // 专辑封面
        albumCoverView.wantsLayer = true
        albumCoverView.layer?.cornerRadius = 4
        albumCoverView.imageScaling = NSImageScaling.scaleAxesIndependently
        albumCoverView.clipsToBounds = true
        
        // 歌曲标题
        songTitleLabel.isEditable = false
        songTitleLabel.isBordered = false
        songTitleLabel.backgroundColor = .clear
        songTitleLabel.textColor = .white
        songTitleLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        songTitleLabel.lineBreakMode = .byTruncatingTail
        
        // 艺术家名称
        artistLabel.isEditable = false
        artistLabel.isBordered = false
        artistLabel.backgroundColor = .clear
        artistLabel.textColor = .lightGray
        artistLabel.font = NSFont.systemFont(ofSize: 11)
        artistLabel.lineBreakMode = .byTruncatingTail
        
        // 进度条
        progressSlider.minValue = 0
        progressSlider.maxValue = 100
        progressSlider.floatValue = 0
        progressSlider.isContinuous = true
        progressSlider.target = self
        progressSlider.action = #selector(progressSliderChanged(_:))
        
        // 时间标签
        timeLabel.isEditable = false
        timeLabel.isBordered = false
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = .lightGray
        timeLabel.font = NSFont.systemFont(ofSize: 10)
        timeLabel.stringValue = "0:00"
        
        // 总时长标签
        durationLabel.isEditable = false
        durationLabel.isBordered = false
        durationLabel.backgroundColor = .clear
        durationLabel.textColor = .lightGray
        durationLabel.font = NSFont.systemFont(ofSize: 10)
        durationLabel.stringValue = "0:00"
        
        // 音量滑块
        volumeSlider.minValue = 0
        volumeSlider.maxValue = 1
        volumeSlider.floatValue = 0.8
        volumeSlider.isContinuous = true
        volumeSlider.target = self
        volumeSlider.action = #selector(volumeSliderChanged(_:))
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
}
    
