//
//  PlayerScreenView.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/04.
//

import Foundation
import SwiftUI
import Combine
import AVKit
import MediaPlayer

protocol PlayerScreenViewDelegate{
    func onPlayerPersistKeyReady(contentId:String?,ckcData:Data?)
    func onPlayerAssetInfo(_ info:AssetPlayerInfo)
    func onPlayerError(_ error:PlayerStreamError)
    func onPlayerError(playerError:PlayerError)
    func onPlayerCompleted()
    func onPlayerBecomeActive()
    func onPlayerBitrateChanged(_ bitrate:Double)
    func onPlayerSubtltle(_ langs:[PlayerLangType])
    func onPipStatusChange(_ isStart:Bool)
    func onPipStatusChanged(_ isStart:Bool)
    func onPipClosed(isStop:Bool)
}

protocol PlayerScreenPlayerDelegate{
    func onPlayerReady()
    func onPlayerDestory()
}

class PlayerScreenView: UIView, PageProtocol, CustomAssetPlayerDelegate , AVPictureInPictureControllerDelegate, Identifiable{
    let appTag = "myTvPlayer"
    let id:String = UUID.init().uuidString
    var viewModel:PlayerModel? = nil
    var delegate:PlayerScreenViewDelegate? = nil
    var playerDelegate:PlayerScreenPlayerDelegate? = nil
    var drmData:FairPlayDrm? = nil
    var playerController : UIViewController? = nil
    var playerLayer:AVPlayerLayer? = nil
    var pipController:AVPictureInPictureController? = nil
   // private var observer: NSKeyValueObservation?
    private(set) var player:CustomAssetPlayer? = nil
    {
        didSet{
            if player != nil {
                if let pl = playerLayer {
                    layer.addSublayer(pl)
                }
            }
        }
    }

    private var currentTimeObservser:Any? = nil
    private(set) var currentVolume:Float = 1.0
    var isAutoPlay:Bool = false
    private var initTime:Double = 0
    private var recoveryTime:Double = -1
 
    var usePip:Bool = false
    private var currentUsePip:Bool = false
    private var isPip:Bool = false
    private var isPipClose:Bool = true
    private var isAppPip:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        ComponentLog.d("init " + id, tag: self.tag)
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    deinit {
        ComponentLog.d("deinit " + id, tag: self.tag)
        self.destoryScreenview()
    }
    
    func stop() {
        ComponentLog.d("on Stop", tag: self.tag)
        guard let player = self.player else {return}
        player.pause()
        player.stop()
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        player.replaceCurrentItem(with: nil)
        //self.destoryPlayer()
    }
    func destory(){
        ComponentLog.d("destory " + id , tag: self.tag)
        self.destoryPlayer()
        self.destoryScreenview()
    }
    func destoryScreenview(){
        self.playerLayer = nil
        self.delegate = nil
        self.playerController = nil
        self.player = nil
        ComponentLog.d("destoryScreenview " + id, tag: self.tag)
    }
    private func destoryPlayer(){
        if self.isPip {
            self.isPip = false
            self.delegate?.onPipStatusChanged(false)
        }
        self.stop()
        playerLayer?.removeFromSuperlayer()
        playerLayer?.player = nil
        if let avPlayerViewController = playerController as? AVPlayerViewController {
            avPlayerViewController.player = nil
            avPlayerViewController.delegate = nil
        }
        NotificationCenter.default.removeObserver(self)
        self.playerDelegate?.onPlayerDestory()
        self.player?.stop()
        self.pipController = nil
        self.playerLayer = nil
        self.playerDelegate = nil
        self.player = nil
        ComponentLog.d("destoryPlayer " + id, tag: self.tag)
    }
    
    private func createdPlayer(){
        self.playerDelegate?.onPlayerReady()
        let center = NotificationCenter.default
        center.addObserver( self, selector:#selector(failedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object:self.appTag)
        center.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: self.appTag)
        center.addObserver(self, selector: #selector(playerDidBecomeActive), name: UIApplication.didBecomeActiveNotification , object:self.appTag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width * currentRatio
        let h = bounds.height * currentRatio
        let x = (bounds.width - w) / 2
        let y = (bounds.height - h) / 2
        playerLayer?.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func createPlayer(_ url:URL, buffer:Double = 2.0, header:[String:String]? = nil, assetInfo:AssetPlayerInfo? = nil) -> AVPlayer?{
      
        var player:AVPlayer? = nil
        if self.drmData != nil {
            player = startPlayer(url, assetInfo:assetInfo)
        }else if let header = header {
            player = startPlayer(url, header: header)
        }else{
            player = startPlayer(url, assetInfo:assetInfo)
        }
        return player
    }
    
    private func startPlayer(_ url:URL, header:[String:String]) -> AVPlayer?{
       
        let player = self.player ?? CustomAssetPlayer()
        var assetHeader = [String: Any]()
        assetHeader["AVURLAssetHTTPHeaderFieldsKey"] = header
        let key = "playable"
        let asset = AVURLAsset(url: url, options: assetHeader)
        asset.loadValuesAsynchronously(forKeys: [key]){
            DispatchQueue.global(qos: .background).async {
                let status = asset.statusOfValue(forKey: key, error: nil)
                switch (status)
                {
                case AVKeyValueStatus.failed, AVKeyValueStatus.cancelled, AVKeyValueStatus.unknown:
                    ComponentLog.d("certification fail " + url.absoluteString , tag: self.tag)
                    DispatchQueue.main.async {
                        self.onError(.certification(status.rawValue.description))
                    }
                default:
                    //ComponentLog.d("certification success " + url.absoluteString , tag: self.tag)
                    DispatchQueue.main.async {
                        let item = AVPlayerItem(asset: asset)
                        player.replaceCurrentItem(with: item )
                        self.startPlayer(player:player)
                    }
                    break;
                }
            }
        }
        return player
    }
    
    private func startPlayer(_ url:URL, assetInfo:AssetPlayerInfo? = nil)  -> AVPlayer?{
        ComponentLog.d("DrmData " +  (drmData?.contentId ?? " none drm") , tag: self.tag)
        let player = self.player ?? CustomAssetPlayer()
        player.pause()
        if self.drmData == nil {
            player.play(m3u8URL: url)
        } else {
            player.play(m3u8URL: url, playerDelegate: self, assetInfo:assetInfo, drm: self.drmData)
        }
        self.startPlayer(player:player)
        return player
    }
    
    private func startPlayer(player:CustomAssetPlayer){
        if self.player == nil {
            if self.playerLayer == nil {
                self.playerLayer = AVPlayerLayer()
            }
            self.player = player
            player.allowsExternalPlayback = false
            player.usesExternalPlaybackWhileExternalScreenIsActive = true
            player.preventsDisplaySleepDuringVideoPlayback = true
            player.appliesMediaSelectionCriteriaAutomatically = false
            //player.preventsDisplaySleepDuringVideoPlayback = true
            
            player.volume = self.currentVolume
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            }
            catch {
                ComponentLog.e("Setting category to AVAudioSessionCategoryPlayback failed." , tag: self.tag)
            }
            
            if let avPlayerViewController = self.playerController as? AVPlayerViewController {
                avPlayerViewController.player = player
                avPlayerViewController.updatesNowPlayingInfoCenter = false
                avPlayerViewController.videoGravity = self.currentVideoGravity
                avPlayerViewController.allowsPictureInPicturePlayback = self.usePip
            }else{
                self.playerLayer?.player = player
                self.playerLayer?.contentsScale = self.currentRatio
                self.playerLayer?.videoGravity = self.currentVideoGravity                
            }
            
            ComponentLog.d("startPlayer currentVolume " + self.currentVolume.description , tag: self.tag)
            ComponentLog.d("startPlayer currentRate " + self.currentRate.description , tag: self.tag)
            ComponentLog.d("startPlayer videoGravity " + self.currentVideoGravity.rawValue , tag: self.tag)
            self.createdPlayer()
            self.setupPictureInPicture()
        }
       
    }
    func setupPictureInPicture() {
        guard let layer = self.playerLayer else {return}
        if !self.usePip {
            if self.isPip {
                self.onPipStop()
            }
            self.currentUsePip = false
            pipController?.delegate = nil
            pipController = nil
            return

        }
        // Ensure PiP is supported by current device.
        if AVPictureInPictureController.isPictureInPictureSupported() {
            if !self.currentUsePip {
                pipController = AVPictureInPictureController(playerLayer: layer)
                
                if #available(iOS 14.2, *) {
                    pipController?.canStartPictureInPictureAutomaticallyFromInline = true
                } 
                pipController?.delegate = self
                self.currentUsePip = true
            }
        
        } else {
            self.currentUsePip = false
            pipController = nil
        }
    }

    private func onError(_ e:PlayerStreamError){
        delegate?.onPlayerError(e)
        ComponentLog.e("onError " + e.getDescription(), tag: self.tag)
        if self.isPip {
            self.pip(isStart: false)
        }
        switch e {
        case .playbackSection : break
        default : destoryScreenview()
        }
    }
    
    @objc func newErrorLogEntry(_ notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return}
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        ComponentLog.d("errorLog " + errorLog.description , tag: self.tag)
    }

    @objc func failedToPlayToEndTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let e = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]
        if let error = e as? NSError {
            let code = error.code
            if code == -1102 { // 재생구간 오류
                onError(.playbackSection(error.localizedDescription))
            } else {
                onError(.playback(error.localizedDescription))
            }
        }else{
            onError(.unknown("failedToPlayToEndTime"))
        }
        
    }
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        delegate?.onPlayerCompleted()
    }
    @objc func playerDidBecomeActive(notification: NSNotification) {
        delegate?.onPlayerBecomeActive()
    }
   
    @objc func playerItemBitrateChange(notification: NSNotification) {
        DispatchQueue.global(qos: .background).async {
            guard let item = notification.object as? AVPlayerItem else {return}
            guard let bitrate = item.accessLog()?.events.last?.indicatedBitrate else {return}
            DispatchQueue.main.async {
                self.delegate?.onPlayerBitrateChanged(bitrate)
            }
        }
       
    }
    
    @discardableResult
    func load(_ path:String, isAutoPlay:Bool = false , initTime:Double = 0,buffer:Double = 2.0,
              header:[String:String]? = nil,
              assetInfo:AssetPlayerInfo? = nil,
              drmData:FairPlayDrm? = nil
              ) -> AVPlayer? {
        
        var assetURL:URL? = nil
        if path.hasPrefix("http") {
            assetURL = URL(string: path)
        } else {
            assetURL = URL(fileURLWithPath: path)
        }
        guard let url = assetURL else { return nil }
        
        self.initTime = initTime
        self.isAutoPlay = isAutoPlay
        self.drmData = drmData
        let player = createPlayer(url, buffer:buffer, header:header, assetInfo: assetInfo)
        return player
    }
    
    func playInit(){
        DispatchQueue.main.async {
            if self.isAutoPlay { self.resume() }
            else { self.pause() }
        }
        self.checkCaption()
    }
    func playInit(duration:Double){
       
        guard let currentPlayer = player else { return }
        if self.currentRate != 1 {
            DispatchQueue.main.async {
                currentPlayer.rate = self.currentRate
            }
        }
        DispatchQueue.main.async {
            if self.isAutoPlay { self.resume() }
            else { self.pause() }
            if ceil(self.initTime) > 0 && duration > 0 {
                let diff:Double = duration - self.initTime
                let seekAble = self.viewModel?.isSeekAble ?? true
                DataLog.d("continuousTime " + seekAble.description + " diff " + diff.description, tag: self.tag)
                if seekAble && diff < PlayerModel.SEEK_TIME_MAX  {
                    DataLog.d("continuousTime cancel " + diff.description + " " + self.initTime.description , tag: self.tag)
                    return
                }
                DataLog.d("continuousTime " + self.initTime.description, tag: self.tag)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                    self.seek(self.initTime)
                }
            }
        }
        self.checkCaption()
    }
    
    private func checkCaption(){
        guard let currentItem = self.player?.currentItem else { return }
        var langs:[PlayerLangType] = []
        DispatchQueue.global(qos: .background).async {
            currentItem.asset.allMediaSelections.forEach{ item in
                //DataLog.d(item.debugDescription, tag: self.tag)
                if let find = PlayerLangType.allCases.first(where: { lang in
                    let info = item.debugDescription
                    let key = "language = " + lang.rawValue
                    let sbtKey = "sbtl"
                    return info.contains(key) && info.contains(sbtKey)
                }) {
                    langs.append(find)
                }
            }
            DispatchQueue.main.async {
                self.delegate?.onPlayerSubtltle(langs)
            }
        }
        /*
         Task {
             await self.doCheckCaption(item:currentItem)
         }
        */
    }
    /*
    private func doCheckCaption(item:AVPlayerItem) async {
        var langs:[PlayerLangType] = []
        do{
            try await item.asset.load(.allMediaSelections).forEach{ item in
                if let find = PlayerLangType.allCases.first(where: { lang in
                    let info = item.debugDescription
                    let key = "language = " + lang.rawValue
                    let sbtKey = "sbtl"
                    return info.contains(key) && info.contains(sbtKey)
                }) {
                    langs.append(find)
                }
            }
            DispatchQueue.main.async {
                self.delegate?.onPlayerSubtltle(langs)
            }
        } catch {
           
        }
    }
    */
    
    @discardableResult
    func resume() -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.play()
        currentPlayer.rate = currentRate
        return true
    }
    
    @discardableResult
    func pause() -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.pause()
        
        return true
    }
    
    @discardableResult
    func seek(_ t:Double) -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.currentItem?.cancelPendingSeeks()
        let rt = round(t)
        ComponentLog.d("onSeek request " + rt.description, tag: self.tag)
        let cmt = CMTime(
            value: CMTimeValue(rt * PlayerModel.TIME_SCALE),
            timescale: CMTimeScale(PlayerModel.TIME_SCALE))

        currentPlayer.seek(to: cmt)
        return true
    }
    
    @discardableResult
    func seekMove(_ t:Double) -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.currentItem?.cancelPendingSeeks()
        ComponentLog.d("onSeek move request " + t.description, tag: self.tag)
        let rt = round(t) + Double(currentPlayer.currentItem?.currentTime().seconds ?? 0)
        return self.seek(rt)
    }
    
    
    @discardableResult
    func mute(_ isMute:Bool) -> Bool {
        currentVolume = isMute ? 0.0 : 1.0
        guard let currentPlayer = player else { return false }
        currentPlayer.volume = currentVolume
        return true
    }
    
    func movePlayerVolume(_ v:Float){
        guard let currentPlayer = player else { return }
        withAnimation{
            currentPlayer.volume = v
        }
    }
    
    func setArtwork(_ imageData:UIImage){
        guard let item = self.player?.currentItem else {return}
        guard let data = imageData.jpegData(compressionQuality: 1) as? NSData else {return}
        let artwork = AVMutableMetadataItem()
        artwork.identifier = .commonIdentifierArtwork
        artwork.value = data
        artwork.dataType = kCMMetadataBaseDataType_JPEG as String
        artwork.extendedLanguageTag = "und"
        item.externalMetadata = [artwork]
    }
    
    @discardableResult
    func pip(isStart:Bool) -> Bool {
        guard let pip = self.pipController else { return false }
        self.isAppPip = true
        DispatchQueue.main.async {
            isStart ? pip.startPictureInPicture() : pip.stopPictureInPicture()
        }
        return true
    }
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        pictureInPictureController.requiresLinearPlayback = !(self.viewModel?.isSeekAble ?? true)
        if !self.isAppPip {
            self.delegate?.onPipStatusChange(true)
        }
        self.isPip = true
        self.isPipClose = true
        self.isAppPip = false
        self.delegate?.onPipStatusChanged(true)
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.onPipStop()
    }
    
    private func onPipStop(){
        if !self.isAppPip {
            self.delegate?.onPipStatusChange(false)
        }
        self.isPip = false
        self.isAppPip = false
        self.delegate?.onPipStatusChanged(false)
        self.delegate?.onPipClosed(isStop: self.isPipClose)
        if self.player?.rate != 0 {
            self.player?.rate = currentRate
        }
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        ComponentLog.d("failedToStartPictureInPictureWithError " + error.localizedDescription ,tag: "pipController")
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        self.isPipClose = false
        ComponentLog.d("restoreUserInterfaceForPictureInPictureStopWithCompletionHandler" ,tag: "pipController")
    }

   
    func captionChange(lang:String?, size:CGFloat?, color:Color?){
        guard let currentPlayer = player else { return }
        guard let currentItem = currentPlayer.currentItem else { return }
        if let group = currentItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            let locale = Locale(identifier: lang ?? "")
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if lang?.isEmpty == false {
                if let option = options.first {
                    currentItem.select(option, in: group)
                }
            }else {
                currentItem.select(nil, in: group)
            }
        }
        let size = (size ?? 100)
        // let component = color.components()
        guard let rule = AVTextStyleRule(textMarkupAttributes: [
            kCMTextMarkupAttribute_RelativeFontSize as String : size,
            kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection as String: 77
        ]) else { return }
        /*
        guard let rule = AVTextStyleRule(textMarkupAttributes: [
            kCMTextMarkupAttribute_RelativeFontSize as String : size,
            kCMTextMarkupAttribute_ForegroundColorARGB as String : [component.a ,component.r,component.g,component.b]
        ]) else { return }
         */
        currentItem.textStyleRules = [rule]
    }
    
    // asset delegate
    func onFindAllInfo(_ info: AssetPlayerInfo) {
        self.delegate?.onPlayerAssetInfo(info)
    }
    
    func onAssetLoadError(_ error: PlayerError) {
        self.delegate?.onPlayerError(playerError: error)
    }
    
    func onAssetEvent(_ evt :AssetLoadEvent) {
        switch evt {
        case .keyReady(let contentId, let ckcData):
            self.delegate?.onPlayerPersistKeyReady(contentId:contentId, ckcData: ckcData)
            if self.isAutoPlay { self.resume() }
            else { self.pause() }
        }
    }
    
    var currentPlayTime:Double? {
        get{
            self.player?.currentItem?.currentTime().seconds
        }
    }
    
    
    var currentRatio:CGFloat = 1.0
    {
        didSet{
            ComponentLog.d("onCurrentRatio " + currentRatio.description, tag: self.tag)
            if let layer = playerLayer {
                layer.contentsScale = currentRatio
                self.setNeedsLayout()
            }
        }
    }
    
    var currentVideoGravity:AVLayerVideoGravity = .resizeAspectFill
    {
        didSet{
             playerLayer?.videoGravity = currentVideoGravity
             if let avPlayerViewController = playerController as? AVPlayerViewController {
                 avPlayerViewController.videoGravity = currentVideoGravity
             }
        }
    }
    
    var currentRate:Float = 1.0
    {
        didSet{
            
            player?.rate = currentRate
        }
    }
    
}


