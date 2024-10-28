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
        public static let add = "add"
        public static let edit = "edit"
        public static let select = "select"
        public static let selectMulti = "selectMulti"
        public static let selectAll = "selectAll"
        public static let cameraReset = "cameraReset"
        public static let trash = "trash"
        public static let bind = "bind"
        public static let separate = "separate"
        public static let conbine = "conbine"
        public static let cross = "cross"
        public static let cube = "cube"
        public static let cubes = "cubes"
        public static let cubeAll = "cubeAll"
        
        public static let save = "save"
        public static let saveList = "saveList"
        public static let gridOn = "gridOn"
        public static let gridOff = "gridOff"
        
        public static let arrow = "arrow"
        public static let arrowLong = "arrowLong"
        public static let arrowRotate = "arrowRotate"
        
        public static let rectRotate = "rectRotate"
        public static let rectRotateL = "rectRotateL"
        public static let rectRotateR = "rectRotateR"
        public static let rectArrow = "rectArrow"
        public static let crop = "crop"
        public static let share = "share"
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
