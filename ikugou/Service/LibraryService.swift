//
//  LibraryService.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/6.
//
import SwiftUI
import Foundation

/// 音乐库服务 - 负责音乐库相关的所有业务逻辑
@Observable
class LibraryService {
    static let shared = LibraryService()
    private let userService = UserService.shared
    
    // MARK: - 听歌历史相关
    
    /// 听歌历史列表
    var listenHistory: [ListenHistoryItem] = []
    
    /// 听歌历史加载状态
    var isLoadingListenHistory = false
    
    /// 听歌历史错误信息
    var listenHistoryError: String?
    
    // MARK: - 最近播放相关
    
    /// 最近播放列表
    var recentlyPlayed: [Song] = []
    
    /// 最近播放加载状态
    var isLoadingRecentlyPlayed = false
    
    /// 最近播放错误信息
    var recentlyPlayedError: String?
    
    // MARK: - 我的歌单相关
    
    /// 我的歌单列表
    var myPlaylists: [UserPlaylistResponse.UserPlaylist] = []
    
    /// 我的歌单加载状态
    var isLoadingMyPlaylists = false
    
    /// 我的歌单错误信息
    var myPlaylistsError: String?
    
    // MARK: - 关注的歌手相关
    
    /// 关注的歌手列表
    var followedArtists: [UserFollowResponse.FollowArtist] = []
    
    /// 收藏的朋友列表
    var collectedFriends: [UserFollowResponse.FollowArtist] = []
    
    /// 关注数据加载状态
    var isLoadingFollowData = false
    
    /// 关注数据错误信息
    var followDataError: String?
    
    // MARK: - 喜欢的音乐相关
    
    /// 喜欢的音乐列表
    var likedSongs: [Song] = []
    
    /// 喜欢的音乐加载状态
    var isLoadingLikedSongs = false
    
    /// 喜欢的音乐错误信息
    var likedSongsError: String?
    
    private init() {}
    
    // MARK: - 听歌历史方法
    
    /// 获取听歌历史数据
    /// - Parameter type: 历史类型，默认为1
    /// - Returns: 随机排序的听歌历史项目数组（最多16个）
    func getListenHistory(type: Int = 1) async {
        guard userService.isLoggedIn else {
            await MainActor.run {
                listenHistoryError = "用户未登录"
            }
            return
        }
        
        await MainActor.run {
            isLoadingListenHistory = true
            listenHistoryError = nil
        }
        
        do {
            let historyItems = try await getListenHistoryItems(type: type)
            
            await MainActor.run {
                self.listenHistory = historyItems
                self.isLoadingListenHistory = false
            }
        } catch {
            await MainActor.run {
                self.listenHistoryError = error.localizedDescription
                self.isLoadingListenHistory = false
                self.listenHistory = []
            }
        }
    }
    
    /// 获取听歌历史
    private func getListenHistoryItems(type: Int = 1) async throws -> [ListenHistoryItem] {
        do {
            let params = ["type": String(type)]
            
            let response: ListenHistoryResponse = try await NetworkService.shared.get(
                endpoint: "/user/listen",
                params: params,
                responseType: ListenHistoryResponse.self
            )
            
            if response.status == 1, let data = response.data, let allLists = data.lists {
                // 随机打乱数组，类似JavaScript的 sort(() => 0.5 - Math.random())
                let shuffledLists = allLists.shuffled()
                
                // 取前16个，如果不足16个则返回全部
                let limitedLists = Array(shuffledLists.prefix(16))
                
                return limitedLists
            } else {
                throw UserServiceError.serverError(response.error_code, "获取听歌历史失败")
            }
        } catch let error as NetworkError {
            throw UserServiceError.networkError(error.localizedDescription)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.unknownError
        }
    }
    
    /// 刷新听歌历史
    func refreshListenHistory() async {
        await getListenHistory()
    }
    
    /// 清除听歌历史
    func clearListenHistory() {
        listenHistory = []
        listenHistoryError = nil
    }
    
    // MARK: - 听歌历史数据格式化方法
    
    /// 获取格式化的歌曲信息
    func getFormattedSongInfo(from item: ListenHistoryItem) -> (title: String, artist: String, album: String) {
        let title = item.songname ?? "未知歌曲"
        let artist = item.singername ?? "未知歌手"
        let album = item.albumname ?? "未知专辑"
        
        return (title, artist, album)
    }
    
    /// 获取专辑封面URL（处理HTTPS和尺寸占位符）
    func getAlbumCoverURL(from item: ListenHistoryItem) -> String? {
        guard let albumImg = item.album_img else { return nil }
        
        // 使用统一的图片URL处理工具
        return ImageURLHelper.processImageURL(albumImg, size: .small)?.absoluteString
    }
    
    /// 格式化播放时间
    func formatListenTime(from item: ListenHistoryItem) -> String {
        guard let listenTime = item.listen_time else { return "" }
        
        // 这里可以根据需要格式化时间显示
        // 例如：将时间戳转换为相对时间（"2小时前"、"昨天"等）
        return listenTime
    }
    
    /// 格式化歌曲时长
    func formatDuration(from item: ListenHistoryItem) -> String {
        guard let duration = item.duration, duration > 0 else { return "" }
        
        let minutes = duration / 60
        let seconds = duration % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - 最近播放方法
    
    /// 获取最近播放
    func getRecentlyPlayed() async {
        guard userService.isLoggedIn else {
            await MainActor.run {
                recentlyPlayedError = "用户未登录"
            }
            return
        }
        
        await MainActor.run {
            isLoadingRecentlyPlayed = true
            recentlyPlayedError = nil
        }
        
        // 这里可以实现获取最近播放的逻辑
        // 目前使用模拟数据
        await MainActor.run {
            self.recentlyPlayed = []
            self.isLoadingRecentlyPlayed = false
        }
    }
    
    // MARK: - 我的歌单方法
    
    /// 获取我的歌单
    func getMyPlaylists() async {
        guard userService.isLoggedIn else {
            await MainActor.run {
                myPlaylistsError = "用户未登录"
            }
            return
        }
        
        await MainActor.run {
            isLoadingMyPlaylists = true
            myPlaylistsError = nil
        }
        
        do {
            let playlistData = try await getUserPlaylists()
            
            await MainActor.run {
                self.myPlaylists = playlistData.info ?? []
                self.isLoadingMyPlaylists = false
            }
        } catch {
            await MainActor.run {
                self.myPlaylistsError = error.localizedDescription
                self.isLoadingMyPlaylists = false
                self.myPlaylists = []
            }
        }
    }
    
    /// 获取用户歌单
    private func getUserPlaylists() async throws -> UserPlaylistResponse.UserPlaylistData {
        do {
            let response: UserPlaylistResponse = try await NetworkService.shared.get(
                endpoint: "/user/playlist",
                responseType: UserPlaylistResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return data
            } else {
                throw UserServiceError.serverError(response.error_code, "获取用户歌单失败")
            }
        } catch let error as NetworkError {
            throw UserServiceError.networkError(error.localizedDescription)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.unknownError
        }
    }
    
    // MARK: - 关注的歌手方法
    
    /// 获取关注的歌手和收藏的朋友
    func getFollowData() async {
        guard userService.isLoggedIn else {
            await MainActor.run {
                followDataError = "用户未登录"
            }
            return
        }
        
        await MainActor.run {
            isLoadingFollowData = true
            followDataError = nil
        }
        
        do {
            let (collectedFriends, followedArtists) = try await getCategorizedFollowData()
            
            await MainActor.run {
                self.collectedFriends = collectedFriends
                self.followedArtists = followedArtists
                self.isLoadingFollowData = false
            }
        } catch {
            await MainActor.run {
                self.followDataError = error.localizedDescription
                self.isLoadingFollowData = false
                self.collectedFriends = []
                self.followedArtists = []
            }
        }
    }
    
    /// 获取用户关注的歌手
    private func getUserFollowedArtists() async throws -> UserFollowResponse.UserFollowData {
        do {
            let response: UserFollowResponse = try await NetworkService.shared.get(
                endpoint: "/user/follow",
                responseType: UserFollowResponse.self
            )
            
            if response.status == 1, let data = response.data {
                return data
            } else {
                throw UserServiceError.serverError(response.error_code, "获取关注歌手失败")
            }
        } catch let error as NetworkError {
            throw UserServiceError.networkError(error.localizedDescription)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.unknownError
        }
    }
    
    /// 获取分类后的关注数据
    private func getCategorizedFollowData() async throws -> (collectedFriends: [UserFollowResponse.FollowArtist], followedArtists: [UserFollowResponse.FollowArtist]) {
        let followData = try await getUserFollowedArtists()
        
        guard let total = followData.total, total > 0,
              let lists = followData.lists else {
            return ([], [])
        }
        
        // 处理图片URL，将100尺寸替换为480尺寸
        let processedArtists = lists.map { artist in
            var processedArtist = artist
            if let pic = artist.pic {
                let enhancedPic = pic.replacingOccurrences(of: "/100/", with: "/480/")
                processedArtist = UserFollowResponse.FollowArtist(
                    userid: artist.userid,
                    username: artist.username,
                    nickname: artist.nickname,
                    pic: enhancedPic,
                    singerid: artist.singerid,
                    source: artist.source,
                    follow_time: artist.follow_time,
                    sex: artist.sex,
                    birthday: artist.birthday,
                    intro: artist.intro,
                    fans_count: artist.fans_count,
                    follow_count: artist.follow_count
                )
            }
            return processedArtist
        }
        
        // 分类：收藏的朋友（没有singerid）和关注的歌手（source == 7）
        let collectedFriends = processedArtists.filter { $0.singerid == nil || $0.singerid?.isEmpty == true }
        let followedArtists = processedArtists.filter { $0.source == 7 }
        
        return (collectedFriends, followedArtists)
    }
    
    // MARK: - 喜欢的音乐方法
    
    /// 获取喜欢的音乐
    func getLikedSongs() async {
        guard userService.isLoggedIn else {
            await MainActor.run {
                likedSongsError = "用户未登录"
            }
            return
        }
        
        await MainActor.run {
            isLoadingLikedSongs = true
            likedSongsError = nil
        }
        
        // 这里可以实现获取喜欢音乐的逻辑
        // 目前使用模拟数据
        await MainActor.run {
            self.likedSongs = []
            self.isLoadingLikedSongs = false
        }
    }
    
    // MARK: - 歌单详情方法
    
    /// 获取歌单详情
    func getPlaylistDetail(globalCollectionId: String) async throws -> PlaylistDetailInfo? {
        do {
            let params = ["ids": globalCollectionId]
            
            let response: PlaylistDetailResponse = try await NetworkService.shared.get(
                endpoint: "/playlist/detail",
                params: params,
                responseType: PlaylistDetailResponse.self
            )
            
            if response.status == 1, let data = response.data, let info = data.first {
                return info
            } else {
                throw UserServiceError.serverError(response.error_code, "获取歌单详情失败")
            }
        } catch let error as NetworkError {
            throw UserServiceError.networkError(error.localizedDescription)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.unknownError
        }
    }
    
    /// 获取歌单所有歌曲
    func getPlaylistTracks(globalCollectionId: String, page: Int = 1, pageSize: Int = 100) async throws -> [PlaylistTrackInfo] {
        do {
            let params = [
                "id": globalCollectionId,
                "page": String(page),
                "pagesize": String(pageSize)
            ]
            
            let response: PlaylistTracksResponse = try await NetworkService.shared.get(
                endpoint: "/playlist/track/all",
                params: params,
                responseType: PlaylistTracksResponse.self
            )
            
            if response.status == 1, let data = response.data, let tracks = data.songs {
                return tracks
            } else {
                throw UserServiceError.serverError(response.error_code, "获取歌单歌曲失败")
            }
        } catch let error as NetworkError {
            throw UserServiceError.networkError(error.localizedDescription)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.unknownError
        }
    }
    
    // MARK: - 通用方法
    
    /// 刷新指定分类的数据
    func refreshSection(_ section: LibrarySection) async {
        switch section {
        case .myListenedSongs:
            await refreshListenHistory()
        case .myCreatedPlaylists, .myCollectedPlaylists:
            await getMyPlaylists()
        case .myFollowedArtists:
            await getFollowData()
        case .myFollowedFriends:
            await getFollowData()
        case .myCollectedAlbums:
            // TODO: Implement album collection functionality
            break
        }
    }
    
    /// 清除所有数据
    func clearAllData() {
        listenHistory = []
        recentlyPlayed = []
        myPlaylists = []
        followedArtists = []
        collectedFriends = []
        likedSongs = []
        
        listenHistoryError = nil
        recentlyPlayedError = nil
        myPlaylistsError = nil
        followDataError = nil
        likedSongsError = nil
    }
}
