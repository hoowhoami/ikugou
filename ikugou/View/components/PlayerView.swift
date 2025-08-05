//
//  PlayerView.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

struct PlayerView: View {
    /// 全局播放管理器
    @Environment(PlayerManager.self) private var playerManager

    // UI 状态
    @State private var showVolumeSlider = false
    @State private var showSpeedSlider = false
    @State private var showPlaylist = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部进度条
            TopProgressBarView(
                currentTime: Binding(
                    get: { playerManager.currentTime },
                    set: { playerManager.seekTo(time: $0) }
                ),
                duration: playerManager.duration
            )
            // .padding(.horizontal, 16)

            // 主要控制区域
            HStack(spacing: 0) {
                // 左侧：歌曲信息
                SongInfoView(song: playerManager.currentSong)
                    .frame(width: 200)

                // 中央：播放控制（绝对居中）
                HStack {
                    Spacer()
                    PlaybackControlsView(
                        isPlaying: playerManager.isPlaying,
                        onPrevious: { playerManager.playPrevious() },
                        onPlayPause: { playerManager.togglePlayback() },
                        onNext: { playerManager.playNext() }
                    )
                    Spacer()
                }

                // 右侧：播放模式和设置
                PlayerSettingsView(
                    volume: Binding(
                        get: { playerManager.volume },
                        set: { playerManager.setVolume($0) }
                    ),
                    playbackSpeed: Binding(
                        get: { playerManager.playbackSpeed },
                        set: { playerManager.setPlaybackSpeed($0) }
                    ),
                    playMode: Binding(
                        get: { playerManager.playMode },
                        set: { _ in playerManager.togglePlayMode() }
                    ),
                    showVolumeSlider: $showVolumeSlider,
                    showSpeedSlider: $showSpeedSlider,
                    showPlaylist: $showPlaylist,
                    playerManager: playerManager
                )
                .frame(width: 200)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(height: 80)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            // 顶部边框
            Rectangle()
                .fill(Color(NSColor.separatorColor).opacity(0.5))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}



// 顶部进度条组件
struct TopProgressBarView: View {
    @Binding var currentTime: Double
    let duration: Double
    @State private var isHovering = false
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景条
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: isHovering || isDragging ? 6 : 3)

                // 进度条
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * (currentTime / duration), height: isHovering || isDragging ? 6 : 3)

                // 拖拽手柄（仅在悬停或拖拽时显示）
                if isHovering || isDragging {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 12, height: 12)
                        .offset(x: geometry.size.width * (currentTime / duration) - 6)
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let newTime = (value.location.x / geometry.size.width) * duration
                        currentTime = max(0, min(duration, newTime))
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )

            // 时间提示（仅在悬停时显示）
            if isHovering || isDragging {
                HStack {
                    Text(formatTime(currentTime))
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)
                        .offset(y: -20)

                    Spacer()

                    Text(formatTime(duration))
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)
                        .offset(y: -20)
                }
            }
        }
        .frame(height: isHovering || isDragging ? 20 : 6)
        .animation(.easeInOut(duration: 0.2), value: isHovering)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// 原进度条组件（保留以防其他地方使用）
struct ProgressBarView: View {
    @Binding var currentTime: Double
    let duration: Double

    var body: some View {
        VStack(spacing: 6) {
            // 进度条
            Slider(value: $currentTime, in: 0...duration) {
                // 拖拽时的处理
            } onEditingChanged: { editing in
                // 拖拽开始/结束时的处理
            }
            .controlSize(.small)

            // 时间显示
            HStack {
                Text(formatTime(currentTime))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(formatTime(duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// 歌曲信息组件
struct SongInfoView: View {
    let song: Song?

    var body: some View {
        HStack(spacing: 12) {
            // 封面
            if let song = song {
                Image(song.cover)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.secondary)
                    )
            }

            // 歌曲信息
            VStack(alignment: .leading, spacing: 2) {
                Text(song?.title ?? "未播放")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(song?.artist ?? "未知歌手")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 120, alignment: .leading)
        }
    }
}

// 播放控制组件
struct PlaybackControlsView: View {
    let isPlaying: Bool
    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 上一首
            Button(action: onPrevious) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .onHover { isHovering in
                if isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            // 播放/暂停
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .onHover { isHovering in
                if isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            // 下一首
            Button(action: onNext) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .onHover { isHovering in
                if isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

// 播放器设置组件
struct PlayerSettingsView: View {
    @Binding var volume: Double
    @Binding var playbackSpeed: Double
    @Binding var playMode: PlayMode
    @Binding var showVolumeSlider: Bool
    @Binding var showSpeedSlider: Bool
    @Binding var showPlaylist: Bool
    let playerManager: PlayerManager

    var body: some View {
        HStack(spacing: 16) {
            // 播放模式
            Button(action: {
                // 切换播放模式
                let allModes = PlayMode.allCases
                if let currentIndex = allModes.firstIndex(of: playMode) {
                    let nextIndex = (currentIndex + 1) % allModes.count
                    playMode = allModes[nextIndex]
                }
            }) {
                Image(systemName: playMode.rawValue)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help(playMode.displayName)
            .onHover { isHovering in
                if isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            // 播放速度控制
            Button(action: {
                showSpeedSlider.toggle()
                if showSpeedSlider {
                    showVolumeSlider = false
                    showPlaylist = false
                }
            }) {
                Text(String(format: "%.1fx", playbackSpeed))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(showSpeedSlider ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showSpeedSlider, arrowEdge: .top) {
                SpeedControlPopover(playbackSpeed: $playbackSpeed)
            }
            .onHover { isHovering in
                if isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            // 音量控制
            Button(action: {
                showVolumeSlider.toggle()
                if showVolumeSlider {
                    showSpeedSlider = false
                    showPlaylist = false
                }
            }) {
                Image(systemName: volumeIcon)
                    .font(.system(size: 16))
                    .foregroundColor(showVolumeSlider ? .accentColor : .secondary)
                    .frame(width: 20, alignment: .center) // 固定宽度防止布局变化
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showVolumeSlider, arrowEdge: .top) {
                VolumeControlPopover(volume: $volume)
            }
            .onHover { isHovering in
                if isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            // 播放列表
            Button(action: {
                showPlaylist.toggle()
                if showPlaylist {
                    showVolumeSlider = false
                    showSpeedSlider = false
                }
            }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16))
                    .foregroundColor(showPlaylist ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showPlaylist, arrowEdge: .top) {
                PlaylistPopover(playerManager: playerManager)
            }
            .onHover { isHovering in
                if isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }

    private var volumeIcon: String {
        if volume == 0 {
            return "speaker.slash.fill"
        } else if volume < 0.3 {
            return "speaker.wave.1.fill"
        } else if volume < 0.7 {
            return "speaker.wave.2.fill"
        } else {
            return "speaker.wave.3.fill"
        }
    }
}

// 音量控制弹出窗口
struct VolumeControlPopover: View {
    @Binding var volume: Double

    var body: some View {
        VStack(spacing: 8) {
            Text("\(Int(volume * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            // 简约的横排滑块
            Slider(value: $volume, in: 0...1)
                .frame(width: 120)
                .controlSize(.small)
        }
        .padding(12)
    }
}

// 播放速度控制弹出窗口
struct SpeedControlPopover: View {
    @Binding var playbackSpeed: Double

    private let speedOptions: [Double] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

    var body: some View {
        VStack(spacing: 6) {
            // 预设速度选项
            ForEach(speedOptions, id: \.self) { speed in
                Button(action: {
                    playbackSpeed = speed
                }) {
                    Text("\(speed, specifier: "%.2g")x")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(playbackSpeed == speed ? .white : .primary)
                        .frame(width: 50, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(playbackSpeed == speed ? Color.accentColor : Color.gray.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
                .onHover { isHovering in
                    if isHovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
        }
        .padding(12)
    }
}

// 播放列表弹出窗口
struct PlaylistPopover: View {
    let playerManager: PlayerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题
            HStack {
                Text("播放列表")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(playerManager.playlist.count) 首歌曲")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // 播放列表
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(playerManager.playlist.enumerated()), id: \.element.id) { index, song in
                        PlaylistItemView(
                            song: song,
                            isCurrentSong: index == playerManager.currentIndex,
                            onTap: {
                                playerManager.playSong(at: index)
                            }
                        )

                        if index < playerManager.playlist.count - 1 {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .frame(width: 320)
    }
}

// 播放列表项组件
struct PlaylistItemView: View {
    let song: Song
    let isCurrentSong: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 封面
                Image(song.cover)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(4)
                    .clipped()

                // 歌曲信息
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.subheadline)
                        .fontWeight(isCurrentSong ? .medium : .regular)
                        .foregroundColor(isCurrentSong ? .accentColor : .primary)
                        .lineLimit(1)

                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // 当前播放指示器
                if isCurrentSong {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isCurrentSong ? Color.accentColor.opacity(0.1) : Color.clear)
        .onHover { isHovering in
            if isHovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

#Preview {
    PlayerView()
        .environment(PlayerManager())
}
