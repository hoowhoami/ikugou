//
//  User.swift
//  ikugou
//
//  Created by AI Assistant on 2025/8/5.
//

import Foundation

// MARK: - 用户信息模型
struct User: Codable {
    let userid: Int
    let username: String
    let nickname: String
    let token: String
    let avatar: String?
    let mobile: Int?
    let qq: Int?
    let wechat: Int?
    let sex: Int?
    let birthday: String?
    let birthday_mmdd: String?
    let reg_time: String?
    let servertime: String?
    
    // VIP相关信息
    let is_vip: Int?
    let vip_type: Int?
    let vip_token: String?
    let vip_begin_time: String?
    let vip_end_time: String?
    let su_vip_begin_time: String?
    let su_vip_end_time: String?
    let su_vip_y_endtime: String?
    let su_vip_clearday: String?
    
    // 听歌相关
    let listen_type: Int?
    let listen_begin_time: String?
    let listen_end_time: String?
    let roam_type: Int?
    let roam_begin_time: String?
    let roam_end_time: String?
    
    // 音乐相关
    let m_type: Int?
    let m_begin_time: String?
    let m_end_time: String?
    let m_is_old: Int?
    let y_type: Int?
    
    // 其他字段
    let exp: Int?
    let score: Int?
    let user_type: Int?
    let user_y_type: Int?
    let t_expire_time: Int?
    let totp_server_timestamp: Int?
    let bookvip_valid: Int?
    let bookvip_end_time: String?
    let arttoy_avatar: String?
    let bc_code: String?
    let t1: String?
    
    // 直接创建User的初始化方法（用于QR登录等场景）
    init(userid: Int, username: String, nickname: String, token: String, avatar: String? = nil) {
        self.userid = userid
        self.username = username
        self.nickname = nickname
        self.token = token
        self.avatar = avatar
        
        // 其他字段设为默认值
        self.mobile = nil
        self.qq = nil
        self.wechat = nil
        self.sex = nil
        self.birthday = nil
        self.birthday_mmdd = nil
        self.reg_time = nil
        self.servertime = nil
        
        self.is_vip = nil
        self.vip_type = nil
        self.vip_token = nil
        self.vip_begin_time = nil
        self.vip_end_time = nil
        self.su_vip_begin_time = nil
        self.su_vip_end_time = nil
        self.su_vip_y_endtime = nil
        self.su_vip_clearday = nil
        
        self.listen_type = nil
        self.listen_begin_time = nil
        self.listen_end_time = nil
        self.roam_type = nil
        self.roam_begin_time = nil
        self.roam_end_time = nil
        
        self.m_type = nil
        self.m_begin_time = nil
        self.m_end_time = nil
        self.m_is_old = nil
        self.y_type = nil
        
        self.exp = nil
        self.score = nil
        self.user_type = nil
        self.user_y_type = nil
        self.t_expire_time = nil
        self.totp_server_timestamp = nil
        self.bookvip_valid = nil
        self.bookvip_end_time = nil
        self.arttoy_avatar = nil
        self.bc_code = nil
        self.t1 = nil
    }
    
    // API响应的字段映射
    private enum CodingKeys: String, CodingKey {
        case userid, username, nickname, token
        case avatar = "pic"
        case mobile, qq, wechat, sex, birthday, birthday_mmdd, reg_time, servertime
        case is_vip, vip_type, vip_token, vip_begin_time, vip_end_time
        case su_vip_begin_time, su_vip_end_time, su_vip_y_endtime, su_vip_clearday
        case listen_type, listen_begin_time, listen_end_time
        case roam_type, roam_begin_time, roam_end_time
        case m_type, m_begin_time, m_end_time, m_is_old, y_type
        case exp, score, user_type, user_y_type, t_expire_time, totp_server_timestamp
        case bookvip_valid, bookvip_end_time, arttoy_avatar, bc_code, t1
    }
}

// MARK: - 用户详细信息响应模型
struct UserDetailResponse: Codable {
    let status: Int
    let error_code: Int
    let data: UserDetailData?
    
    struct UserDetailData: Codable {
        let nickname: String?
        let k_nickname: String?
        let fx_nickname: String?
        let kq_talent: Int?
        let pic: String?
        let k_pic: String?
        let fx_pic: String?
        let gender: Int?
        let vip_type: Int?
        let m_type: Int?
        let y_type: Int?
        let descri: String?
        let follows: Int?
        let fans: Int?
        let visitors: Int?
        let constellation: Int?
        let medal: Medal?
        let star_status: Int?
        let star_id: Int?
        let birthday: String?
        let city: String?
        let province: String?
        let occupation: String?
        let bg_pic: String?
        let relation: Int?
        let auth_info: String?
        let auth_info_singer: String?
        let auth_info_talent: String?
        let tme_star_status: Int?
        let biz_status: Int?
        let p_grade: Int?
        let friends: Int?
        let face_auth: Int?
        let avatar_review: Int?
        let servertime: Int?
        let bookvip_valid: Int?
        let iden: Int?
        let is_star: Int?
        let knock_cnt: Int?
        let knock: [String]?
        let real_auth: Int?
        let risk_symbol: Int?
        let user_like: Int?
        let user_is_like: Int?
        let user_likeid: String?
        let top_number: Int?
        let top_version: String?
        let main_short_case: String?
        let main_long_case: String?
        let guest_short_case: String?
        let singer_status: Int?
        let bc_code: String?
        let arttoy_avatar: String?
        let visitor_visible: Int?
        let config_val: Int?
        let config_val1: Int?
        let kuqun_visible: Int?
        let user_type: Int?
        let user_y_type: Int?
        let su_vip_begin_time: String?
        let su_vip_end_time: String?
        let su_vip_clearday: String?
        let su_vip_y_endtime: String?
        let logintime: Int?
        let loc: String?
        let comment_visible: Int?
        let student_visible: Int?
        let followlist_visible: Int?
        let fanslist_visible: Int?
        let info_visible: Int?
        let follow_visible: Int?
        let listen_visible: Int?
        let album_visible: Int?
        let pictorial_visible: Int?
        let radio_visible: Int?
        let sound_visible: Int?
        let applet_visible: Int?
        let selflist_visible: Int?
        let collectlist_visible: Int?
        let lvideo_visible: Int?
        let svideo_visible: Int?
        let mv_visible: Int?
        let ksong_visible: Int?
        let box_visible: Int?
        let nft_visible: Int?
        let musical_visible: Int?
        let live_visible: Int?
        let timbre_visible: Int?
        let assets_visible: Int?
        let online_visible: Int?
        let lting_visible: Int?
        let listenmusic_visible: Int?
        let likemusic_visible: Int?
        let kuelf_visible: Int?
        let share_visible: Int?
        let musicstation_visible: Int?
        let yaicreation_visible: Int?
        let ylikestory_visible: Int?
        let ychannel_visible: Int?
        let ypublishstory_visible: Int?
        let myplayer_visible: Int?
        let usermedal_visible: Int?
        let singletrack_visible: Int?
        let faxingka_visible: Int?
        let ai_song_visible: Int?
        let mcard_visible: Int?
        let hvisitors: Int?
        let nvisitors: Int?
        let rtime: Int?
        let hobby: String?
        let actor_status: Int?
        let remark: String?
        let duration: Int?
        let svip_level: Int?
        let svip_score: Int?
        let visible: Int?
        let k_star: Int?
        let singvip_valid: Int?
    }
    
    struct Medal: Codable {
        let ktv: KTVMedal?
        let fx: FXMedal?
        
        struct KTVMedal: Codable {
            let type3: String?
            let type2: String?
            let type1: String?
        }
        
        struct FXMedal: Codable {
            // Empty for now
        }
    }
}

// MARK: - 用户VIP信息响应模型  
struct UserVipResponse: Codable {
    let status: Int
    let error_code: Int
    let data: UserVipData?
    
    struct UserVipData: Codable {
        let is_vip: Int?
        let roam_type: Int?
        let m_reset_time: String?
        let m_y_endtime: String?
        let vip_clearday: String?
        let vip_type: Int?
        let vip_begin_time: String?
        let roam_begin_time: String?
        let vip_end_time: String?
        let userid: Int?
        let vip_y_endtime: String?
        let m_clearday: String?
        let svip_level: Int?
        let svip_score: Int?
        let su_vip_clearday: String?
        let su_vip_end_time: String?
        let su_vip_y_endtime: String?
        let su_vip_begin_time: String?
        let busi_vip: [BusiVip]?
        let m_begin_time: String?
        let user_y_type: Int?
        let user_type: Int?
        let y_type: Int?
        let m_end_time: String?
        let roam_end_time: String?
        let m_is_old: Int?
        let m_type: Int?
    }
    
    struct BusiVip: Codable {
        let is_vip: Int?
        let purchased_ios_type: Int?
        let purchased_type: Int?
        let is_paid_vip: Int?
        let vip_clearday: String?
        let latest_product_id: String?
        let product_type: String?
        let vip_begin_time: String?
        let y_type: Int?
        let vip_end_time: String?
        let userid: Int?
        let vip_limit_quota: VipLimitQuota?
        let paid_vip_expire_time: String?
        let busi_type: String?
    }
    
    struct VipLimitQuota: Codable {
        let total: Int?
    }
}