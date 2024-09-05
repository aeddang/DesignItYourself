//
//  Player.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import AVKit
import Combine
import SwiftUI

enum PlayerRequest {//input
    case load(String,
              _ autoPlay:Bool? = nil, _ initTime:Double = 0.0,
              _ header:Dictionary<String,String>? = nil,
              seekAble:Bool? = nil),
         togglePlay(isUser:Bool = false),
         resumeDisable(isUser:Bool = false),
         resume(isUser:Bool = false), pause(isUser:Bool = false), stop(isUser:Bool = false),
         volume(Float, isUser:Bool),  rate(Float,isUser:Bool), mute(Bool, isUser:Bool), movePlayerVolume(Float),
         seekTime(Double, Bool? = nil, isUser:Bool), seekProgress(Float, Bool? = nil, isUser:Bool),
         seekMove(Double, Bool? = nil, isUser:Bool),
         seekForward(Double, Bool? = nil, isUser:Bool,seek:Double? = 10),
         seekBackword(Double, Bool? = nil, isUser:Bool,seek:Double? = 10),
         addSeekForward(Double, Bool? = nil, isUser:Bool), addSeekBackword(Double, Bool? = nil, isUser:Bool),
         screenGravity(AVLayerVideoGravity), screenRatio(CGFloat),
         captionChange(lang:String? = nil, size:CGFloat? = nil , color:Color? = nil),
         pip(Bool, isUser:Bool), usePip(Bool),
         requestPlayTime,
         zip([PlayerRequest])
            
    var decription: String {
        switch self {
        case .togglePlay: return "togglePlay"
        case .resume: return "resume"
        case .pause: return "pause"
        case .load: return "load"
        case .stop: return "stop"
        case .volume: return "volume"
        case .seekTime: return "seekTime"
        case .seekProgress: return "seekProgress"
        case .seekMove: return "seekMove"
        case .pip: return "pip"
        default: return ""
        }
    }
}
enum PlayerUiRequest {//input
    case fixUiStatus(Bool), viewProgressStatus(Bool), delayUiStatus,
         timeView(start:String?, end:String?),
         timeRange(start:Double, end:Double, id:String? = nil, isLiveStream:Bool = true),
         sectionPlay([(Double,Double)], idx:Int? = nil), sectionMove(idx:Int), sectionPlayEnd,
         screenTap,
         fullScreen(Bool, isUser:Bool), replay(Bool),
         recovery(isUser:Bool = false),
         playStart
    
}

enum PlayerStreamEvent {//output
    case persistKeyReady(String?, Data?), resumed, paused, loaded(String), buffer,
         stoped, seeked, completed, recovery, pipClosed(Bool),
         next(Double),scheduleOn(Int),
         timeRangeCompleted, sectionPlayCompleted, sectionPlayNext(Int, isUser:Bool = false)
         
}

enum PlayerStatus:String {
    case load, resume, pause, seek, complete, error, stop
}

enum PlayerPipStatus:String {
    case on, off
}

enum PlayerUiStatus:String {
    case view, hidden
}
enum PlayMode:String {
    case normal, section
}

enum PlayerStreamStatus :Equatable{
    case buffering(Double), playing, stop
    
    public static func == (l:PlayerStreamStatus, r:PlayerStreamStatus)-> Bool {
        switch (l, r) {
        case ( .buffering, .buffering):return true
        case ( .playing, .playing):return true
        case ( .stop, .stop):return true
        default: return false
        }
    }
}

enum PlayerLangType:String, CaseIterable{
    case ko, en, ja, zh, vi, ru, ms, id, tl, th, hi
    
    var decription: String {
        switch self {
        case .ko: return "한국어"
        case .en: return "영어"
        case .ja: return "일본어"
        case .zh: return "중국어"
        case .vi: return "베트남어"
        case .ru: return "러시아어"
        case .ms: return "말레이어"
        case .id: return "인도네시아어"
        case .tl: return "필리핀어"
        case .th: return "태국어"
        case .hi: return "인도어"
        }
    }

    static func getType(_ value:String?)->PlayerLangType{
        switch value {
        case "ko": return .ko
        case "en": return .en
        case "ja": return .ja
        case "zh": return .zh
        case "vi": return .vi
        case "ru": return .ru
        case "ms": return .ms
        case "id": return .id
        case "tl": return .tl
        case "th": return .th
        case "hi": return .hi
        default : return .ko
        }
    }
    
        
}

enum PlayerError{
    case connect(String), stream(PlayerStreamError), illegalState(PlayerRequest), drm(DRMError), asset(AssetLoadError)
}
enum PlayerStreamError:Error{
    case playback(String), playbackSection (String), unknown(String), pip(String), certification(String)
    func getDescription() -> String {
        switch self {
        case .pip(let s):
            return "PlayerStreamError pip " + s
        case .playback(let s):
            return "PlayerStreamError playback " + s
        case .playbackSection(let s):
            return "PlayerStreamError playback Section " + s
        case .certification(let s):
            return "PlayerStreamError certification " + s
        case .unknown(let s):
            return "PlayerStreamError unknown " + s
        }
    }
}

enum PlayerUpdateType{
    case initate, update, recovery(Double, count:Int = -1)
}

class FairPlayDrm{
    let ckcURL:String
    let certificateURL:String
    var contentId:String? = nil
    var useOfflineKey:Bool = false
    var certificate:Data? = nil
    var isCompleted:Bool = false
    var persistKeys:[(String,Data,Date)] = []
    init( ckcURL:String,
          certificateURL:String) {
        
        self.ckcURL = ckcURL
        self.certificateURL = certificateURL
            
    }
    init( persistKeys:[(String,Data,Date)]) {
        self.ckcURL = ""
        self.certificateURL = ""
        self.persistKeys = persistKeys
        self.useOfflineKey = true
    }
}



protocol PlayBack:PageProtocol {
    var viewModel:PlayerModel {get set}
    func onStandby()
    func onTimeChange(_ t:Double)
    func onDurationChange(_ t:Double)
    func onLoad()
    func onLoaded()
    func onSeek(time:Double)
    func onSeeked()
    func onResumed()
    func onPaused()
    func onReadyToPlay()
    func onToMinimizeStalls()
    func onBuffering(rate:Double)
    func onBufferCompleted()
    func onStoped()
    func onCompleted()
    func onPipStatusChanged(_ status:PlayerPipStatus)
    func onPipStop(isStop:Bool)
    func onError(_ error:PlayerStreamError)
    func onError(playerError:PlayerError)
    
    
    func onVolumeChange(_ v:Float)
    func onMute(_ isMute:Bool)
    func onScreenRatioChange(_ ratio:CGFloat)
    func onRateChange(_ rate:Float)
    func onScreenGravityChange(_ gravity:AVLayerVideoGravity)
    
    func setAssetInfo(_ info:AssetPlayerInfo)
    func setSubtltle(_ langs: [PlayerLangType])
    func onBitrateChanged(_ bitrate: Double)
}
