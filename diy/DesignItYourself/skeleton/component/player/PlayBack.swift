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

open class PlayerModel: ComponentObservable {
    static let TIME_SCALE:Double = 600
    static let SEEK_TIME_MAX:Double = 10
    
    /*ui setup*/
    var path:String = ""
    var useAvPlayerController:Bool = false
    var useAvPlayerControllerUI:Bool = false
    var useNowPlaying:Bool = false // NowPlayInfo 사용여부
    var useSeeking:Bool = true // 비디오 서치 사용여부
    var usePip:Bool = true
    
    /*play*/
    var isUserPlay = true // 사용자의도로 재생한경우 true
    var isReplay = false
    var isSeekAfterPlay:Bool? = nil //seeking완료 후 자동재생여부
    var isResumeAble:Bool = true //재생 시작시 변경 필요시 false .resumeDisable이벤트로 다음액션 실행
    
    /*drm*/
    var drm:FairPlayDrm? = nil
    private(set) var prevCertificate:Data? = nil
    var header:[String:String]? = nil
    
    
    
    
    var limitedDuration:Double? = nil
    var limitedStartTime:Double = 0
    var checkEventTime:Double? = nil
    var nextEventTime:Double = 60 * 5
    var thumbImagePath:String? = nil
    
    @Published var artImage:String? = nil
    @Published var thumbImage:String? = nil
    @Published var progressColor:Color = Color.brand.primary
    @Published var progressSections:[ProgressSection]? = nil
    @Published var isLock:Bool = false
    @Published var screenOpercity:Double = 1
    @Published var request:PlayerRequest? = nil{
        willSet{
            self.status = .update
        }
        didSet{
            if request == nil { self.status = .ready }
        }
    }
    @Published var playerUiStatus:PlayerUiStatus = .hidden
    @Published var playerUiRequest:PlayerUiRequest? = nil  {didSet{ if playerUiRequest != nil { playerUiRequest = nil} }}
    @Published var error:PlayerError? = nil
    
    @Published fileprivate(set) var volume:Float = -1
    @Published fileprivate(set) var bitrate:Double? = nil
    @Published fileprivate(set) var screenRatio:CGFloat = 1.0
    @Published fileprivate(set) var seeking:Double = 0
    @Published fileprivate(set) var seekingProgress:Float = 0
    @Published fileprivate(set) var isSeekAble:Bool? = nil
    
    @Published fileprivate(set) var rate:Float = 1.0
    @Published fileprivate(set) var assetInfo:AssetPlayerInfo? = nil
    @Published fileprivate(set) var subtitles:[PlayerLangType]? = nil
    @Published fileprivate(set) var screenGravity:AVLayerVideoGravity = .resizeAspect
   
    
    
    @Published fileprivate(set) var playMode:PlayMode = .normal
    @Published fileprivate(set) var isMute:Bool = false
    
    @Published fileprivate(set) var initTime:Double? = nil
    @Published fileprivate(set) var isPlay = false
    @Published fileprivate(set) var duration:Double = 0.0
    @Published fileprivate(set) var isLiveStream:Bool = true
    
    fileprivate(set) var playDuration:Double = 0
    fileprivate(set) var originDuration:Double = 0
    fileprivate(set) var toMinimizeStallsCount:Int = 0
    fileprivate(set) var playTimeRate:Float = 0
    fileprivate(set) var remainingTime:Double = 0
    
    fileprivate(set) var streamStartTime:Double = 0
    fileprivate(set) var playOriginStartTime:Double = 0
    fileprivate(set) var playStartTime:Double = 0
    fileprivate(set) var playEndTime:Double = 0
    fileprivate(set) var isNextFire:Bool = false
    fileprivate(set) var scheduleUnit:Int = 0
    fileprivate(set) var scheduleTime:Int = 0
    fileprivate(set) var currentSectionIdx:Int? = nil
    
    
    @Published fileprivate(set) var time:Double = 0.0
    @Published fileprivate(set) var isRunning = false
   
   
    @Published fileprivate(set) var streamEvent:PlayerStreamEvent? = nil
    @Published fileprivate(set) var playerStatus:PlayerStatus? = nil
    @Published fileprivate(set) var streamStatus:PlayerStreamStatus? = nil
    @Published fileprivate(set) var playerPipStatus:PlayerPipStatus = .off
    
    fileprivate var isInitLoaded:Bool = false
    fileprivate var seekTime:Double? = nil
    
    convenience init(path: String) {
        self.init()
        self.path = path
    }
    
    open func onAppear(){
        self.reset()
        let v = AVAudioSession.sharedInstance().outputVolume
        self.volume = v
        //self.isMute = v == 0 최초 진입시 볼륨과 음소거 동기화 시키지 않음 ?? 이후 볼륨 조작시 동기화
    }
    open func onDisappear(){
        self.request = .stop(isUser: true)
    }
    
    
    
    open func reset(){
        if let cert = self.drm?.certificate {
            prevCertificate = cert
        }
        
        streamStartTime = 0
        playOriginStartTime = 0
        playStartTime = 0
        playEndTime = 0
        scheduleUnit = 0
        scheduleTime = 0
        progressSections = nil
        thumbImagePath = nil
        playTimeRate = 0
        limitedDuration = nil
        limitedStartTime = 0
        screenRatio = 1.0
        rate = 1.0
        header = nil
        path = ""
        drm = nil
        subtitles = nil
        setPlayMode(.normal)
        reload()
    }
    
    open func reload(){
        isInitLoaded = false
        isLiveStream = true
        isPlay = false
        duration = 0
        originDuration = 0
        time = 0
        streamEvent = nil
        playerStatus = nil
        streamStatus = nil
        seeking = 0
        seekingProgress = 0
        error = nil
    }
    
    func setPlayMode(_ mode:PlayMode){
        self.playMode = mode
        switch mode {
        case .section :
            self.isSeekAble = false
        default :
            self.currentSectionIdx = nil
            self.screenOpercity = 1
            self.isSeekAble = self.useSeeking
        }
    }
    
    func initSetup(volume:Float? = nil, mute:Bool? = nil, rate:Float? = nil, screenGravity:AVLayerVideoGravity? = nil){
        if let v = volume { self.volume = v }
        if let v = mute { self.isMute = v }
        if let v = rate { self.rate = v }
        if let v = screenGravity { self.screenGravity = v }
    }
    
    @discardableResult
    func searching(pct:Float)->Double{
        let p = max(min(pct, 1), 0)
        let willTime = self.duration * Double(p)
        self.seeking = willTime
        self.seekingProgress = pct
        return willTime
    }
    
    func setSchedule(_ t:Int){
        self.scheduleUnit = t
        self.scheduleTime = 0
    }
    func setLiveTime(start:Double, end:Double){
        self.isNextFire = false
        let duration = end - start
        self.playOriginStartTime = start
        self.playEndTime = duration
        self.streamStartTime = 0
        self.playStartTime = AppUtil.networkTimeDate().timeIntervalSince1970 - start
    }
    
    func setSectionIndex(_ idx:Int, sectionTime:Double, isUser:Bool = true){
        self.request = .seekTime(sectionTime, isUser: false)
        self.currentSectionIdx = idx
        self.streamEvent = .sectionPlayNext(idx, isUser: isUser)
    }
    func onSectionPlayCompleted(){
        self.streamEvent = .sectionPlayCompleted
    }
    
    func getSeekForwardAmount(t:Double = 10)->Double {
        self.delayAutoResetSeekMove()
        self.seekMove = self.seekMove < 0 ? self.seekMove - t : -t
        return -self.seekMove
    }
    
    func getSeekBackwordAmount(t:Double = 10)->Double {
        self.delayAutoResetSeekMove()
        self.seekMove = self.seekMove > 0 ? self.seekMove + t : t
        return self.seekMove
    }
    
    private(set)var seekMove:Double = 0
    private var autoResetSeekMove:AnyCancellable?
    private func delayAutoResetSeekMove(){
        self.autoResetSeekMove?.cancel()
        self.autoResetSeekMove = Timer.publish(
            every: 1.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.autoResetSeekMove?.cancel()
                self.seekMove = 0
            }
    }
}


extension PlayBack {
    func onStandby(){
        self.viewModel.streamStatus = .buffering(0)
    }
        
    func onTimeChange(_ t:Double){
        guard !(t.isNaN || t.isInfinite) else { return }
        if self.viewModel.isLiveStream {
            self.onLivePlay(t)
        } else {
            self.onVodPlay(t)
            if let checkTime = viewModel.seekTime {
                if abs(checkTime-t) <= 3 {
                    self.checkSeeked()
                }
            }
            
        }
    }
    
    private func onVodPlay(_ t:Double){
        let d = viewModel.duration
        if d <= 0 {return}
        if t < 0 {return}
        let tm = t - self.viewModel.limitedStartTime
        let diff = d - tm
        if !self.viewModel.isNextFire && diff <= self.viewModel.nextEventTime {
            self.viewModel.isNextFire = true
            ComponentLog.d("isNextFire vod " + diff.description, tag:self.tag)
            self.viewModel.streamEvent = .next(diff)
        }
        let progress = Float(tm / d)
        self.viewModel.remainingTime = max(0,diff)
        self.viewModel.playTimeRate = progress
        self.viewModel.time = tm
        self.checkSchcdule()
    }
    
    private func onLivePlay(_ t:Double){
        let d = self.viewModel.playEndTime
        if d <= 0 {return}
        let st = self.viewModel.playStartTime
        let sst = self.viewModel.streamStartTime
        let tm = t + self.viewModel.playStartTime - self.viewModel.streamStartTime
        let diff = d - tm
        if !self.viewModel.isNextFire && diff <= self.viewModel.nextEventTime && diff > 2 {
            self.viewModel.isNextFire = true
            ComponentLog.d("isNextFire live", tag:self.tag)
            self.viewModel.streamEvent = .next(diff)
        }
        let progress = Float(tm / d)
        self.viewModel.remainingTime = max(0,diff)
        self.viewModel.playTimeRate = progress
        self.viewModel.time = tm
        if tm >= d {
            ComponentLog.d("player completed Test timeRangeCompleted", tag:self.tag)
            self.viewModel.streamEvent = .timeRangeCompleted
            return
        }
        self.checkSchcdule()
    }
    
    private func checkSchcdule(){
        if self.viewModel.scheduleUnit < 1 {return}
        let t = self.viewModel.scheduleTime + 1
        if (t % self.viewModel.scheduleUnit) == 0 {
            self.viewModel.streamEvent = .scheduleOn(t)
        }
        self.viewModel.scheduleTime = t
    }
    
    
    func onDurationChange(_ t:Double){
        if t <= 0 { return }
        viewModel.isLiveStream = false
        viewModel.originDuration = t
        if let limit = viewModel.limitedDuration {
            viewModel.duration = min(t, limit) - viewModel.limitedStartTime
        }else{
            viewModel.duration = t - viewModel.limitedStartTime
        }
    }
    
    func onPersistKeyReady(contentId:String?, ckcData:Data?){
        viewModel.streamEvent = .persistKeyReady(contentId, ckcData)
    }
    
    func onLoad(){
        ComponentLog.d("onLoad", tag: self.tag)
        self.checkSeeked()
        viewModel.playerStatus = .load
        
    }
    func onLoaded(){
        ComponentLog.d("onLoaded", tag: self.tag)
        viewModel.isInitLoaded = true
        viewModel.streamEvent = .loaded(viewModel.path)
    }
    func onSeek(time:Double){
        if viewModel.playerStatus == .error {
            ComponentLog.d("error reload", tag: self.tag)
            return
        }
        let t = time
        ComponentLog.d("onSeek " + t.description, tag: self.tag)
        viewModel.seekTime = t
        viewModel.playerStatus = .seek
        if abs(t-viewModel.time) <= 1 {
            self.checkSeeked()
        }
        //onBuffering()
    }
    func checkSeeked(){
        switch self.viewModel.playerStatus {
        case .seek: onSeeked()
        default: break
        }
    }
    
    func onSeeked(){
        ComponentLog.d("onSeeked " + viewModel.isPlay.description, tag: self.tag)
        viewModel.seekTime = nil
        viewModel.seeking = 0
        viewModel.streamEvent = .seeked
        viewModel.playerStatus = viewModel.isPlay ? .resume : .pause
        if let afterPlay = viewModel.isSeekAfterPlay {
            DispatchQueue.main.async {
                viewModel.request = afterPlay ? .resume(): .pause()
                viewModel.isSeekAfterPlay = nil
            }
        }
    }
    func onResumed(){
        self.checkSeeked()
        //ComponentLog.d("onResumed", tag: self.tag)
        if self.viewModel.playEndTime > 0 {
            let originTime = self.viewModel.time - self.viewModel.playStartTime
            self.viewModel.playStartTime = AppUtil.networkTimeDate().timeIntervalSince1970 - self.viewModel.playOriginStartTime
            self.viewModel.streamStartTime = originTime
        }
        self.viewModel.isPlay = true
        self.viewModel.streamEvent = .resumed
        self.viewModel.playerStatus = .resume
       
        onBufferCompleted()
    }
    func onPaused(){
        self.checkSeeked()
        viewModel.isPlay = false
        if viewModel.playerStatus == .complete
            || viewModel.playerStatus == .error {
            return
        }
        viewModel.streamEvent = .paused
        viewModel.playerStatus = .pause
        if self.viewModel.toMinimizeStallsCount > 1 {
            onError(.playback("toMinimizeStalls"))
            onBufferCompleted()
        } else {
            onBufferCompleted()
        }
    }
    func onReadyToPlay(){
        ComponentLog.d("onReadyToPlay", tag: self.tag)
        onBufferCompleted()
        switch self.viewModel.playerStatus {
        case .load: onLoaded()
        case .seek: onSeeked()
        default: break
        }
        if !self.viewModel.isInitLoaded {onLoaded()}
    }
    func onToMinimizeStalls(){
        self.viewModel.toMinimizeStallsCount += 1
        onBuffering(rate:0)
    }
    func onBuffering(rate:Double = 0){
        viewModel.streamEvent = .buffer
        viewModel.streamStatus = .buffering(rate)
    }
    
    func onBufferCompleted(){
        self.checkSeeked()
        viewModel.toMinimizeStallsCount = 0
        viewModel.streamStatus = .playing
    }
    
    func onStoped(){
        if viewModel.playerStatus == .error || viewModel.playerStatus == .stop{
            ComponentLog.d("already stoped", tag: self.tag)
            return
        }
        ComponentLog.d("onStoped", tag: self.tag)
        
        viewModel.streamEvent = .stoped
        viewModel.playerStatus = .stop
        viewModel.streamStatus = .stop
    }
    
    func onCompleted(){
        let d = self.viewModel.duration //광고플레이어에서도 동일한 이벤트 날림...
        if d <= 0 {return}
        if viewModel.playerStatus == .complete {return}
        ComponentLog.d("onCompleted", tag: self.tag)
        viewModel.streamEvent = .completed
        viewModel.playerStatus = .complete
    }
    func onPipStatusChanged(_ status:PlayerPipStatus){
        viewModel.playerPipStatus = status
    }
    func onPipStop(isStop:Bool){
        viewModel.streamEvent = .pipClosed(isStop)
    }
    func onError(_ error:PlayerStreamError){
        ComponentLog.e("onError" + error.getDescription(), tag: self.tag)
        viewModel.error = .stream(error)
        switch error {
        case .playbackSection :
            self.onCompleted()
            return
        default : break
        }
        
        viewModel.streamEvent = .stoped
        viewModel.streamStatus = .stop
        viewModel.playerStatus = .error
        
    }
    
    func onError(playerError:PlayerError){
        DispatchQueue.main.async {
            viewModel.error = playerError
            viewModel.streamEvent = .stoped
            viewModel.streamStatus = .stop
            viewModel.playerStatus = .error
        }
    }
    
    func onVolumeChange(_ v:Float){
        self.viewModel.volume = v
    }
    func onMute(_ isMute:Bool){
        self.viewModel.isMute = isMute
        /* 음소거 해재시 볼륨 0이면 그대로 0
        if isMute {return}
        if self.viewModel.volume == 0 {
            self.viewModel.request = .volume(0.5, isUser: true)
        }
        */
    }
    func onScreenRatioChange(_ ratio:CGFloat){
        self.viewModel.screenRatio = ratio
    }
    func onRateChange(_ rate:Float){
        self.viewModel.rate = rate
    }
    func onScreenGravityChange(_ gravity:AVLayerVideoGravity){
        self.viewModel.screenGravity = gravity
        self.viewModel.screenRatio = 1
    }
    
    func setAssetInfo(_ info:AssetPlayerInfo) {
        self.viewModel.assetInfo = info
    }
    
    func setSubtltle(_ langs: [PlayerLangType]) {
        self.viewModel.subtitles = langs
    }
    func onBitrateChanged(_ bitrate: Double) {
        self.viewModel.bitrate = bitrate
    }
}
