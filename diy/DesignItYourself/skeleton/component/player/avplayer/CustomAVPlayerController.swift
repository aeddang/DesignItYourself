//
//  CustomCamera.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/22.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVKit
import MediaPlayer

extension CustomAVPlayerController: UIViewControllerRepresentable,
                                    PlayBack, PlayerScreenViewDelegate , CustomPlayerControllerDelegate{
    fileprivate static let systemVolume = "outputVolume"
    fileprivate(set) static var currentPlayer:[String] = []
    fileprivate(set) static var currentPlayerNum:Int  = 0
    
    static var isSyncSystemVolume:Bool = true
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomAVPlayerController>) -> UIViewController {
        let playerScreenView = PlayerScreenView(frame: .infinite)
        playerScreenView.mute(self.viewModel.isMute)
        playerScreenView.currentRate = self.viewModel.rate
        playerScreenView.currentVideoGravity = self.viewModel.screenGravity
        playerScreenView.currentRatio = self.viewModel.screenRatio
        playerScreenView.viewModel = self.viewModel
        DispatchQueue.main.async {
            self.onStandby()
        }
        
        if self.viewModel.useAvPlayerController {
            let playerController = CustomAVPlayerViewController(viewModel: self.viewModel, playerScreenView: playerScreenView)
            playerScreenView.delegate = self
            playerScreenView.playerDelegate = playerController
            playerScreenView.playerController = playerController
            playerController.delegate = context.coordinator
            playerController.playerDelegate = self
            playerController.showsPlaybackControls = self.viewModel.useAvPlayerControllerUI
            playerController.allowsPictureInPicturePlayback = self.viewModel.usePip
            if #available(iOS 14.2, *) {
                playerController.canStartPictureInPictureAutomaticallyFromInline = self.viewModel.usePip
            }
            return playerController
        }else{
            let playerController = CustomPlayerViewController(viewModel: self.viewModel, playerScreenView: playerScreenView)
            playerScreenView.delegate = self
            playerScreenView.playerDelegate = playerController
            let layer = AVPlayerLayer()
            layer.frame = playerScreenView.frame
            playerScreenView.playerLayer = layer
            playerController.view = playerScreenView
            playerController.playerDelegate = self
            return playerController
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CustomAVPlayerController>) {
       
        if viewModel.status != .update { return }
        guard let evt = viewModel.request else { return }
        DataLog.d(evt.decription, tag: "updateUIView")
        guard let playerController = uiViewController as? CustomPlayerController else { return }
        DispatchQueue.main.async {
            self.updateExcute(playerController, evt:evt)
        }
    }
  
    private func updateExcute(_ playerController:CustomPlayerController, evt:PlayerRequest) {
        viewModel.request = nil
        DataLog.d(evt.decription, tag: "updateExcute")
        switch evt {
        case .zip(let requests) :
            requests.forEach{
                self.updateExcute(playerController, evt:$0)
            }
            return
        default : break
        }
        
        let player = playerController.playerScreenView
        switch evt {
        case .load(let path, let isAutoPlay, let initTime, let header, let seekAble):
            let autoPlay = isAutoPlay ?? self.viewModel.isUserPlay
            if let able = seekAble { viewModel.useSeeking = able }
            viewModel.reload()
            if path == "" {return}
            viewModel.path = path
            self.onLoad()
            player.usePip = self.viewModel.usePip
            player.currentRate = self.viewModel.rate
            player.currentVideoGravity = self.viewModel.screenGravity
            player.currentRatio = self.viewModel.screenRatio
            player.mute(viewModel.isMute)
            let t = initTime != 0 ? initTime : self.viewModel.limitedStartTime
            player.load(path, isAutoPlay:autoPlay, initTime: t, header:header, assetInfo: self.viewModel.assetInfo, drmData: viewModel.drm)
       
        case .togglePlay(let isUser):
            if self.viewModel.isPlay {
                if isUser { self.viewModel.isUserPlay = false }
                onPause()
            }
            else {
                if isUser { self.viewModel.isUserPlay = true }
                onResume()
            }
        case .resume(let isUser):
            if isUser { self.viewModel.isUserPlay = true }
            onResume()
        case .pause(let isUser):
            if isUser { self.viewModel.isUserPlay = false }
            onPause()
        case .stop:
            viewModel.reset()
            player.stop() 
            self.onStoped()
        case .volume(let v, _):
            MPVolumeView.setVolume(v)
            self.onVolumeChange(v)
            if v > 0 && player.currentVolume == 0 {
                self.onMute(false)
                player.mute(false)
            } else if v == 0 {
                player.mute(true)
            }
        case .movePlayerVolume(let pct) :
            let v = viewModel.volume * pct
            player.movePlayerVolume(v)
        case .mute(let isMute, _):
            self.onMute(isMute)
            player.mute(isMute)
        case .screenRatio(let r):
            player.currentRatio = r
            self.onScreenRatioChange(r)
            
        case .rate(let r, _):
            player.currentRate = r
            self.onRateChange(r)
           
        case .screenGravity(let gravity):
            player.currentVideoGravity = gravity
            player.currentRatio = 1
            self.onScreenGravityChange(gravity)
           
        case .seekTime(let t, let play, _): onSeek(time:t, play: play)
        case .seekMove(let t, let play, _): onSeek(time:viewModel.time + t, play: play)
        case .seekForward(let t, let play, _, let seek): onSeek(time:viewModel.time + (seek ?? t) , play: play)
        case .seekBackword(let t, let play, _, let seek): onSeek(time:viewModel.time - (seek ?? t) , play: play)
        case .seekProgress(let pct, let play, _):
            let t = viewModel.duration * Double(pct)
            onSeek(time:t, play: play)
        case .captionChange(let lang, let size, let color) :
            player.captionChange(lang: lang, size: size, color: color)
        case .pip(let isStart, _) :
            player.pip(isStart: isStart)
        case .usePip(let use) :
            player.usePip = use
            viewModel.usePip = use
            if let con = player.playerController as? CustomAVPlayerViewController {
                con.allowsPictureInPicturePlayback = use
            } else {
                player.setupPictureInPicture()
            }
        case .requestPlayTime :
            if let t = player.player?.currentTime().seconds {
                self.onTimeChange(t) 
            }
        default : break 
        }
        
        func onResume(){
            if viewModel.playerStatus == .complete {
                onSeek(time: 0, play:true)
                return
            }
            if !player.resume() {
                viewModel.error = .illegalState(evt)
                return
            }
        }
        func onPause(){
            if !player.pause() { viewModel.error = .illegalState(evt) }
        }
        
        func onSeek(time:Double, play:Bool?){
            var st = min(time, (self.viewModel.limitedDuration ?? self.viewModel.originDuration) - 1 )
            st = max(st, 0) + viewModel.limitedStartTime
            viewModel.isSeekAfterPlay = play
            if !player.seek(st) { viewModel.error = .illegalState(evt) }
            self.onSeek(time: st)
            if self.viewModel.isRunning {return}
        }
        
        func onSeekMove(time:Double, play:Bool?){
            var st = min(time, (self.viewModel.limitedDuration ?? self.viewModel.originDuration) - 1 )
            st = max(st, 0) + viewModel.limitedStartTime
            viewModel.isSeekAfterPlay = play
            if !player.seekMove(st) { viewModel.error = .illegalState(evt) }
            self.onSeek(time: st)
            if self.viewModel.isRunning {return}
        }
    }
    
    
    func onPlayerPersistKeyReady(contentId:String? , ckcData:Data? = nil) {
        DispatchQueue.main.async {
            self.onPersistKeyReady(contentId:contentId, ckcData: ckcData)
        }
    }
    func onPlayerAssetInfo(_ info:AssetPlayerInfo) {
        DispatchQueue.main.async {
            self.setAssetInfo(info)
        }
    }
    
    func onPlayerSubtltle(_ langs: [PlayerLangType]) {
        DispatchQueue.main.async {
            self.setSubtltle(langs)
        }
    }
    
    func onPlayerCompleted(){
        self.onCompleted()
    }

    func onPlayerError(_ error:PlayerStreamError){
        self.onPaused()
        self.onError(error)
    }
    
    func onPlayerError(playerError:PlayerError){
        self.onError(playerError:playerError)
    }

    func onPlayerBecomeActive(){
        
    }
    func onPlayerVolumeChanged(_ v:Float){
        if self.viewModel.volume == -1 {
            self.onVolumeChange(v)
            return
        }
        if self.viewModel.volume == v {return}
        self.onVolumeChange(v)
        self.viewModel.request = .volume(v, isUser: false)
    }
    func onPlayerBitrateChanged(_ bitrate: Double) {
        self.onBitrateChanged(bitrate)
    }
    func onPlayerTimeChange(_ playerController: CustomPlayerController, t:CMTime){
        let t = CMTimeGetSeconds(t)
        self.timeChange(playerController, t: Double(t))
        
    }
    private func timeChange(_ playerController: CustomPlayerController, t:Double){
        let d = viewModel.limitedDuration ?? viewModel.originDuration
        if d > 0 {
           if t >= d {
                if viewModel.playerStatus != .seek {
                    playerController.playerScreenView.player?.pause()
                    self.onTimeChange(viewModel.duration)
                    self.onPaused()
                    self.onCompleted()
                    return
                }
            }
            if viewModel.isReplay && t >= (d - 1) {
                self.viewModel.request = .seekTime(0, true, isUser: false)
            }
        }
        self.onTimeChange(t)
    }
    
    func onPlayerTimeControlChange(_ playerController: CustomPlayerController, status:AVPlayer.TimeControlStatus){
        switch status {
        case .paused:
            DispatchQueue.main.async {
                let prevPlay = self.viewModel.isPlay
                self.onPaused()
                if !prevPlay {return}
                if let t = playerController.playerScreenView.player?.currentTime().seconds {
                    self.timeChange(playerController, t: t+1)
                }
            }
        case .playing:
            DispatchQueue.main.async {
                if let t = playerController.playerScreenView.player?.currentTime().seconds {
                    self.onTimeChange(t)
                }
                self.onResumed()
            }
        case .waitingToPlayAtSpecifiedRate:
            DispatchQueue.main.async {self.onBuffering(rate: 0.0)}
        default:break
        }
    }
    func onPlayerStatusChange(_ playerController: CustomPlayerController, status:AVPlayer.Status){
        switch status {
        case .failed:
            DispatchQueue.main.async {
                self.onPlayerError(.playback("failed"))
            }
        case .unknown:break
        case .readyToPlay:
            DispatchQueue.main.async {
                self.onReadyToPlay()
            }
    
        @unknown default:break
        }
    }
    func onReasonForWaitingToPlay(_ playerController: CustomPlayerController, reason:AVPlayer.WaitingReason){
        switch reason {
        case .evaluatingBufferingRate:
            DispatchQueue.main.async {self.onBuffering(rate: 0.0)}
        case .noItemToPlay:
            DispatchQueue.main.async {self.onBuffering(rate: 0.0)}
        case .toMinimizeStalls:
            DispatchQueue.main.async {self.onToMinimizeStalls()}
        default:break
        }
    }
    
    func onPlayerItemStatusChange(_ playerController: CustomPlayerController, status:AVPlayerItem.Status){
        switch status {
        case .failed:
            ComponentLog.d("onPlayerItemStatusChange failed" , tag: self.tag)
            DispatchQueue.main.async {
                self.onPlayerError(.playback("failed"))
            }
        case .unknown:
            ComponentLog.d("onPlayerItemStatusChange unknown" , tag: self.tag)
        case .readyToPlay:
            ComponentLog.d("onPlayerItemStatusChange readyToPlay" , tag: self.tag)
            if viewModel.originDuration < 1 {
                DispatchQueue.global(qos: .default).async {
                    if let player = playerController.playerScreenView.player {
                        if let d = player.currentItem?.asset.duration {
                            let willDuration = Double(CMTimeGetSeconds(d))
                            if willDuration > 0 {
                                DispatchQueue.main.async {
                                    self.onDurationChange(willDuration)
                                    playerController.playerScreenView.playInit(duration: willDuration)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    playerController.playerScreenView.playInit()
                                }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.onReadyToPlay()
            }
        @unknown default:break
        }
    }
    
    func onPipStatusChanged(_ isStart:Bool){
        self.onPipStatusChanged(isStart ? .on : .off)
    }
    func onPipStatusChange(_ isStart:Bool){
        self.viewModel.request = .pip(isStart, isUser: true)
    }
    func onPipClosed(isStop:Bool){
        self.onPipStop(isStop: isStop)
    }
}


struct CustomAVPlayerController {
    @ObservedObject var viewModel:PlayerModel
    var useRemotePlayer:Bool = true
    
    func makeCoordinator() -> Coordinator { return Coordinator(viewModel:self.viewModel ) }
    
    class Coordinator:NSObject, AVPlayerViewControllerDelegate, PageProtocol {
      
        var viewModel:PlayerModel
        init(viewModel:PlayerModel){
            self.viewModel = viewModel
        }
        func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator){
        }
        func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator){
        }

        func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController){
            ComponentLog.d("playerViewControllerWillStartPictureInPicture" , tag: self.tag)
        }

        func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController){
            ComponentLog.d("playerViewControllerDidStartPictureInPicture" , tag: self.tag)
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error){
            self.viewModel.error = .stream(.pip(error.localizedDescription))
        }

        func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController){
            ComponentLog.d("playerViewControllerWillStopPictureInPicture" , tag: self.tag)
        }

        func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController){
            ComponentLog.d("playerViewControllerDidStopPictureInPicture" , tag: self.tag)
        }

        func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool{
            ComponentLog.d("playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart" , tag: self.tag)
            return false
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler:
                                    @escaping (Bool) -> Void){
            ComponentLog.d("crestoreUserInterfaceForPictureInPictureStopWithCompletionHandler" , tag: self.tag)
        }
    }
}

protocol CustomPlayerControllerDelegate{
    func onPlayerTimeChange(_ playerController: CustomPlayerController, t:CMTime)
    func onPlayerTimeControlChange(_ playerController: CustomPlayerController, status:AVPlayer.TimeControlStatus)
    func onPlayerStatusChange(_ playerController: CustomPlayerController, status:AVPlayer.Status)
    func onPlayerItemStatusChange(_ playerController: CustomPlayerController, status:AVPlayerItem.Status)
    func onReasonForWaitingToPlay(_ playerController: CustomPlayerController, reason:AVPlayer.WaitingReason)
    func onPlayerVolumeChanged(_ v:Float)
}

protocol CustomPlayerController {
    var viewModel:PlayerModel { get set }
    var playerScreenView:PlayerScreenView  { get set }
    var playerDelegate:CustomPlayerControllerDelegate?  { get set }
    var currentTimeObservser:Any? { get set }
    
    func run()
    func cancel()
}

extension CustomPlayerController {
    func onViewDidAppear(_ animated: Bool) {
        if CustomAVPlayerController.currentPlayerNum == 0 {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
        }
        CustomAVPlayerController.currentPlayerNum += 1
        ComponentLog.d("currentPlayerNum " + CustomAVPlayerController.currentPlayerNum.description, tag:"CustomAVPlayerController")
    }
    func onViewWillDisappear(_ animated: Bool) {
        /*
        self.cancel()
        self.playerScreenView.destory()
        CustomAVPlayerController.currentPlayerNum -= 1
        ComponentLog.d("currentPlayerNum " + CustomAVPlayerController.currentPlayerNum.description, tag:"CustomAVPlayerController2")
        if CustomAVPlayerController.currentPlayerNum == 0 {
            UIApplication.shared.endReceivingRemoteControlEvents()
        }*/
    }
    
    func onViewDidDisappear(_ animated: Bool) {
        self.cancel()
        self.playerScreenView.destory()
        CustomAVPlayerController.currentPlayerNum -= 1
        ComponentLog.d("currentPlayerNum " + CustomAVPlayerController.currentPlayerNum.description, tag:"CustomAVPlayerController")
        if CustomAVPlayerController.currentPlayerNum == 0 {
            UIApplication.shared.endReceivingRemoteControlEvents()
        }
    }
    
    func onRemoteControlReceived(with event: UIEvent?) {
        guard let type = event?.type else { return}
        if type != .remoteControl { return }
        if !self.viewModel.useNowPlaying {return}
        switch event!.subtype {
        case .remoteControlPause:
            self.viewModel.request = .pause(isUser:true)
        case .remoteControlPlay:
            self.viewModel.request = .resume(isUser:true)
        case .remoteControlEndSeekingForward:
            if self.viewModel.isSeekAble == false {return}
            self.viewModel.request = .seekForward(15, true, isUser: true)
        case .remoteControlEndSeekingBackward:
            if self.viewModel.isSeekAble == false {return}
            self.viewModel.request = .seekBackword(15, true, isUser: true)
        case .remoteControlNextTrack:
            if self.viewModel.isSeekAble == false {return}
            self.viewModel.request = .seekForward(15, true, isUser: true)
        case .remoteControlPreviousTrack:
            if self.viewModel.isSeekAble == false {return}
            self.viewModel.request = .seekBackword(15, true, isUser: true)
        default: break
        }
    }
    
    func onPlayerItemStatusChange(_ playerController: CustomPlayerController, status:AVPlayerItem.Status){}
    func onReasonForWaitingToPlay(_ playerController: CustomPlayerController, reason:AVPlayer.WaitingReason){}
}

open class CustomPlayerViewController: UIViewController, CustomPlayerController , PlayerScreenPlayerDelegate{
    var playerDelegate: CustomPlayerControllerDelegate? = nil
    var playerScreenView: PlayerScreenView
    var viewModel:PlayerModel
    var useRemotePlayer:Bool = true
    var currentTimeObservser:Any? = nil
    init(viewModel:PlayerModel, playerScreenView:PlayerScreenView) {
        self.viewModel = viewModel
        self.playerScreenView = playerScreenView
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var canBecomeFirstResponder: Bool { return true }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let id = self.playerScreenView.id
        if CustomAVPlayerController.currentPlayer.first(where: {$0 == id}) == nil {
            CustomAVPlayerController.currentPlayer.append(id)
            self.onViewDidAppear(animated)
        }
        self.becomeFirstResponder()
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let id = self.playerScreenView.id
        if let find = CustomAVPlayerController.currentPlayer.firstIndex(of:id) {
            CustomAVPlayerController.currentPlayer.remove(at: find)
            self.onViewDidDisappear(animated)
        }
        self.resignFirstResponder()
    }
     
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    open override func remoteControlReceived(with event: UIEvent?) {
        self.onRemoteControlReceived(with: event)
    }
    
    func onPlayerReady() {
        self.run()
    }
    
    func onPlayerDestory() {
        self.cancel() 
    }
    
    func run(){
        guard let player = self.playerScreenView.player else {return}
        DispatchQueue.global(qos: .background).async {
            self.currentTimeObservser = player.addPeriodicTimeObserver(
                forInterval: CMTimeMakeWithSeconds(1,preferredTimescale: Int32(NSEC_PER_SEC)),
                queue: .main){ time in
                self.playerDelegate?.onPlayerTimeChange(self, t:time)
            }
        }
        //player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
        //player.addObserver(self, forKeyPath: #keyPath(AVPlayer.reasonForWaitingToPlay), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options:[.new], context: nil)
        AVAudioSession.sharedInstance()
            .addObserver(self, forKeyPath: CustomAVPlayerController.systemVolume, options: NSKeyValueObservingOptions.new, context: nil)
         
    }
    func cancel() {
        guard let player = self.playerScreenView.player else {return}
        guard let currentTimeObservser = self.currentTimeObservser else {return}
        player.removeTimeObserver(currentTimeObservser)
        //player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        //player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.reasonForWaitingToPlay))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: CustomAVPlayerController.systemVolume)
        self.currentTimeObservser = nil
    }
    
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?){
        
        switch keyPath {
        case #keyPath(AVPlayer.status) :
            if let num = change?[.newKey] as? Int {
                self.playerDelegate?.onPlayerStatusChange(self, status: AVPlayer.Status(rawValue: num) ?? .unknown)
            } else {
                self.playerDelegate?.onPlayerStatusChange(self, status: .unknown)
            }
        case #keyPath(AVPlayer.currentItem.status) :
            if let num = change?[.newKey] as? Int {
                self.playerDelegate?.onPlayerItemStatusChange(self, status: AVPlayerItem.Status(rawValue: num) ?? .unknown)
            } else {
                self.playerDelegate?.onPlayerItemStatusChange(self, status: .unknown)
            }
        case #keyPath(AVPlayer.timeControlStatus) :
            if let num = change?[.newKey] as? Int,
               let status = AVPlayer.TimeControlStatus(rawValue: num) {
                self.playerDelegate?.onPlayerTimeControlChange(self, status: status)
            }
        case #keyPath(AVPlayer.reasonForWaitingToPlay) :
            if let str = change?[.newKey] as? String{
                let reason = AVPlayer.WaitingReason(rawValue: str)
                self.playerDelegate?.onReasonForWaitingToPlay(self, reason: reason)
            }
        case CustomAVPlayerController.systemVolume :
            if !CustomAVPlayerController.isSyncSystemVolume {return}
            
            let audioSession = AVAudioSession.sharedInstance()
            let volume = audioSession.outputVolume
            ComponentLog.d("systemVolume changed " + volume.description, tag: "AVAudioSession")
            self.playerDelegate?.onPlayerVolumeChanged(volume)
    
        default : break
        
        }
    }
}


extension MPVolumeView {
    static func moveVolume(_ move: Float) -> Void {
        let volumeView = MPVolumeView(frame: .zero)
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
       
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            guard let prev = slider else {return}
            let preV = prev.value
            DataLog.d("prev " + preV.description, tag:"MPVolumeView")
            DataLog.d("move " + move.description, tag:"MPVolumeView")
            let v = preV + move
            prev.value = v
        }
    }
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView(frame: .zero)
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
            DataLog.d("slider " + volume.description, tag:"MPVolumeView")
        }
        
    }
}

//기본UI
open class CustomAVPlayerViewController: AVPlayerViewController, CustomPlayerController, PlayerScreenPlayerDelegate {
    var viewModel:PlayerModel
    var playerScreenView: PlayerScreenView
    var playerDelegate:CustomPlayerControllerDelegate?
    var currentTimeObservser:Any? = nil
    
    init(viewModel:PlayerModel, playerScreenView:PlayerScreenView) {
        self.viewModel = viewModel
        self.playerScreenView = playerScreenView
        super.init(nibName: nil, bundle: nil)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override var canBecomeFirstResponder: Bool { return true }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let id = self.playerScreenView.id
        if CustomAVPlayerController.currentPlayer.first(where: {$0 == id}) == nil {
            CustomAVPlayerController.currentPlayer.append(id)
            self.onViewDidAppear(animated)
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let id = self.playerScreenView.id
        if let find = CustomAVPlayerController.currentPlayer.firstIndex(of:id) {
            CustomAVPlayerController.currentPlayer.remove(at: find)
            self.onViewWillDisappear(animated)
        }
    }
    
    open override func remoteControlReceived(with event: UIEvent?) {
        self.onRemoteControlReceived(with: event)
    }
    
    func onPlayerReady() {
        self.run()
    }
    func onPlayerDestory() {
        self.cancel()
    }
    
    func run(){
        guard let player = self.playerScreenView.player else {return}
        DispatchQueue.global(qos: .background).async {
            self.currentTimeObservser = player.addPeriodicTimeObserver(
                forInterval: CMTimeMakeWithSeconds(1,preferredTimescale: Int32(NSEC_PER_SEC)),
                queue: .main){ time in
                self.playerDelegate?.onPlayerTimeChange(self, t:time)
            }
        }
        //player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
        //player.addObserver(self, forKeyPath: #keyPath(AVPlayer.reasonForWaitingToPlay), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options:[.new], context: nil)
        AVAudioSession.sharedInstance()
            .addObserver(self, forKeyPath: CustomAVPlayerController.systemVolume, options: NSKeyValueObservingOptions.new, context: nil)
         
    }
    func cancel() {
        guard let player = self.playerScreenView.player else {return}
        guard let currentTimeObservser = self.currentTimeObservser else {return}
        player.removeTimeObserver(currentTimeObservser)
        //player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        //player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.reasonForWaitingToPlay))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: CustomAVPlayerController.systemVolume)
        self.currentTimeObservser = nil
    }
    
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?){
        
        
        switch keyPath {
        case #keyPath(AVPlayer.status) :
            if let num = change?[.newKey] as? Int {
                self.playerDelegate?.onPlayerStatusChange(self, status: AVPlayer.Status(rawValue: num) ?? .unknown)
            } else {
                self.playerDelegate?.onPlayerStatusChange(self, status: .unknown)
            }
        case #keyPath(AVPlayer.currentItem.status) :
            if let num = change?[.newKey] as? Int {
                self.playerDelegate?.onPlayerItemStatusChange(self, status: AVPlayerItem.Status(rawValue: num) ?? .unknown)
            } else {
                self.playerDelegate?.onPlayerItemStatusChange(self, status: .unknown)
            }
        case #keyPath(AVPlayer.timeControlStatus) :
            if let num = change?[.newKey] as? Int,
               let status = AVPlayer.TimeControlStatus(rawValue: num) {
                self.playerDelegate?.onPlayerTimeControlChange(self, status: status)
            }
        case #keyPath(AVPlayer.reasonForWaitingToPlay) :
            if let str = change?[.newKey] as? String{
                let reason = AVPlayer.WaitingReason(rawValue: str)
                self.playerDelegate?.onReasonForWaitingToPlay(self, reason: reason)
            }
        case CustomAVPlayerController.systemVolume :
            if !CustomAVPlayerController.isSyncSystemVolume {return}
            let audioSession = AVAudioSession.sharedInstance()
            let volume = audioSession.outputVolume
            self.playerDelegate?.onPlayerVolumeChanged(volume)
        default : break
        
        }
    }
}
