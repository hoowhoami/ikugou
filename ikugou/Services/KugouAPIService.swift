//
//  KugouAPIService.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/3.
//

import Foundation
import Combine

// MARK: - API Response Models
struct KugouSearchResponse: Codable {
    let status: Int
    let error: String
    let data: KugouSearchData
}

struct KugouSearchData: Codable {
    let info: [KugouSongInfo]
    let total: Int
}

struct KugouSongInfo: Codable {
    let hash: String
    let songname: String
    let singername: String
    let album_name: String?
    let duration: Int
    let filesize: Int
    let audio_id: Int
}

struct KugouRankResponse: Codable {
    let status: Int
    let error: String
    let data: KugouRankData
}

struct KugouRankData: Codable {
    let info: [KugouRankSong]
}

struct KugouRankSong: Codable {
    let hash: String
    let filename: String
    let singername: String
    let album_name: String?
    let duration: Int
    let rank: Int
}

struct KugouPlaylistResponse: Codable {
    let status: Int
    let error: String
    let data: KugouPlaylistData
}

struct KugouPlaylistData: Codable {
    let info: [KugouPlaylist]
}

struct KugouPlaylist: Codable {
    let specialid: Int
    let specialname: String
    let imgurl: String?
    let playcount: Int
    let songcount: Int
    let intro: String?
}

// MARK: - API Service
class KugouAPIService: ObservableObject {
    static let shared = KugouAPIService()
    
    private let baseURL = "https://kgmusic-api.vercel.app"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - 搜索歌曲
    func searchSongs(keyword: String, page: Int = 1, pageSize: Int = 30) -> AnyPublisher<KugouSearchResponse, Error> {
        guard let url = URL(string: "\(baseURL)/search?keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)&pagesize=\(pageSize)") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: KugouSearchResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 获取排行榜
    func getRankList(rankId: Int = 8888, page: Int = 1, pageSize: Int = 30) -> AnyPublisher<KugouRankResponse, Error> {
        guard let url = URL(string: "\(baseURL)/rank?rankid=\(rankId)&page=\(page)&pagesize=\(pageSize)") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: KugouRankResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 获取歌单推荐
    func getRecommendedPlaylists(page: Int = 1, pageSize: Int = 20) -> AnyPublisher<KugouPlaylistResponse, Error> {
        guard let url = URL(string: "\(baseURL)/playlist?page=\(page)&pagesize=\(pageSize)") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: KugouPlaylistResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 获取歌曲播放链接
    func getSongURL(hash: String) -> AnyPublisher<String?, Error> {
        guard let url = URL(string: "\(baseURL)/url?hash=\(hash)") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let playUrl = data["play_url"] as? String {
                    return playUrl
                }
                return nil
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 获取歌词
    func getLyrics(hash: String) -> AnyPublisher<String?, Error> {
        guard let url = URL(string: "\(baseURL)/lyric?hash=\(hash)") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let content = data["content"] as? String {
                    return content
                }
                return nil
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - 扩展：转换为应用内模型
extension KugouSongInfo {
    func toSong() -> Song {
        return Song(
            id: hash,
            name: songname,
            artist: singername,
            album: album_name ?? "未知专辑",
            albumCoverUrl: "https://picsum.photos/seed/\(hash)/300/300", // 占位图片
            audioUrl: "", // 需要通过getSongURL获取
            duration: duration,
            trackNumber: 1
        )
    }
}

extension KugouRankSong {
    func toSong() -> Song {
        return Song(
            id: hash,
            name: filename.components(separatedBy: " - ").last ?? filename,
            artist: singername,
            album: album_name ?? "未知专辑",
            albumCoverUrl: "https://picsum.photos/seed/\(hash)/300/300",
            audioUrl: "",
            duration: duration,
            trackNumber: rank
        )
    }
}

extension KugouPlaylist {
    func toPlaylist() -> Playlist {
        return Playlist(
            id: String(specialid),
            name: specialname,
            coverUrl: imgurl ?? "https://picsum.photos/seed/playlist\(specialid)/300/300",
            owner: "酷狗音乐"
        )
    }
}
