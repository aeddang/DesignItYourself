//
//  asset.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/15.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct Asset {}
extension Asset {
    public static let appIcon = "logo"
    public static let appLauncher = "launcher"
}
extension Asset{
    private static let isPad =  AppUtil.isPad()
    struct img {
        public static let splashLogo = "imgSplashCharacter"
        public static let loading = "loading"
        public static let noImg1_1 = "img_1_1"
        public static let noImg9_16 = "img_9_16"
        public static let noImg16_9 = "thumbnail_default_s"
        public static let noImg16_9_w = "img_placeholder_landscape_b"
        public static let noImg16_9_onair = "img_live_future_thumb"
    }
    
    struct icon {
        public static let alert = "alert"
        public static let annotation = "annotation"
        public static let comment = "comment"
        public static let document = "document"
        public static let up = "up"
        public static let down = "down"
        public static let left = "left"
        public static let right = "right"
        public static let camera = "camera"
        public static let globe = "globe"
        public static let edit = "edit"
        public static let picture = "picture"
        public static let pin = "pin"
        public static let setting = "setting"
        public static let add = "add"
        public static let trash = "trash"
        public static let share = "share"
        public static let route = "route"
        
        public static let back = "back"
        public static let next = "next"
        public static let save = "save"
        public static let tag = "tag"
        public static let folder = "folder"
        public static let folder_fill = "folder_fill"
        public static let new = "new"
        public static let question = "question"
        public static let star = "star"
    }
    
    struct component {
        struct button {
            public static let check = "check"
            public static let check_on = "check_on"
            public static let back = "back"
            public static let close = "close"
            public static let down = "drop_down"
            public static let more = "more"
            public static let search = "search"
        }
        struct player {
            public static let resume = "ic_player_play"
            public static let pause = "ic_player_pause"
            public static let refresh = "ic_player_refresh"
            public static let muteOn = "ic_player_mute_on"
            public static let muteOff = "ic_player_mute_off"
            public static let forward = "ic_player_forward"
            public static let backward = "ic_player_backward"
            public static let seekForward = "ic_player_seek_forward"
            public static let seekBackward = "ic_player_seek_back"
            public static let fullScreenOn = "btn_full_screen_on"
            public static let fullScreenOff = "btn_full_screen_off"
        }
       
    }
}
