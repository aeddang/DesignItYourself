import Foundation
import SwiftUI
import Combine
import MediaPlayer
open class PlayerUIModel: ComponentObservable {
    @Published fileprivate(set) var time:String = "00:00:00"
    @Published fileprivate(set) var completeTime:String = "00:00:00"
    @Published fileprivate(set) var duration:String = "00:00:00"
    @Published fileprivate(set) var willTime:String = "00:00"
    @Published fileprivate(set) var startTime:String? = nil
    @Published fileprivate(set) var endTime:String? = nil
    @Published fileprivate(set) var progress:Float = 0

    @Published fileprivate(set) var isError = false
    fileprivate(set) var errorMessage:String? = nil
    
    @Published fileprivate(set) var isLoading = false
    @Published fileprivate(set) var isSeeking = false
    @Published fileprivate(set) var isSoundOn = true
    @Published fileprivate(set) var isShowing: Bool = false
    @Published fileprivate(set) var isProgressShowing: Bool = false
    
    @Published fileprivate(set) var isVodLive:Bool = false
    @Published fileprivate(set) var isLive:Bool = false
    
    @Published fileprivate(set) var seekForward:Int? = nil
    @Published fileprivate(set) var seekBackward:Int? = nil
    
    @Published fileprivate(set) var usePip:Bool = false
    
    fileprivate func reset(){
        self.isProgressShowing = true
        self.progress = 0
        self.startTime = nil
        self.endTime = nil
        self.seekForward = nil
        self.seekBackward = nil
        self.isLive = false
        self.isVodLive = false
    }
    
}

struct CPPlayer<Ui>: PageView where Ui: View {
    @StateObject var imageLoader:AsyncImageLoader = AsyncImageLoader()
    @ObservedObject var viewModel:PlayerModel = PlayerModel()
    var uiModel:PlayerUIModel = PlayerUIModel()
    var useUi:Bool = true
    var useSeekingUi:Bool = true
    var useRemotePlayer:Bool = true
    let ui: Ui
    init(
        imageLoader:AsyncImageLoader? = nil,
        viewModel:PlayerModel? = nil,
        uiModel:PlayerUIModel? = nil,
        useUi:Bool = true,
        useSeekingUi:Bool = true,
        useRemotePlayer:Bool = true,
        @ViewBuilder content: () -> Ui) {
        
            if let v = viewModel { self.viewModel = v }
            if let v = uiModel { self.uiModel = v }
            self.useUi = useUi
            self.useSeekingUi = useSeekingUi
            self.useRemotePlayer = useRemotePlayer
            self.ui = content()
        }
    /*
    var useProgress:Bool = true
    var isStaticUiShow:Bool = false
    var isSimple:Bool = false
    var useRemotePlayer:Bool = true
    var bottomMargin:CGFloat = Dimen.margin.regularExtra
    */
    var body: some View {
        ZStack(alignment: .center){
            CustomAVPlayerController(
                viewModel : self.viewModel,
                useRemotePlayer: self.useRemotePlayer
            )
            .opacity(self.screenOpecity)
            if !self.viewModel.useAvPlayerControllerUI {
                HStack(spacing:0){
                    ZStack{
                        if let seek = self.seekBackward {
                            CPEffect(
                                icon: Asset.component.player.backward,
                                text: seek.description,
                                isReverse: false)
                        }
                        Spacer().modifier(MatchParent())
                            .background(Color.transparent.clearUi)
                            .onTapGesture(count: 2, perform: {
                                if !self.useSeekingUi { return }
                                if self.viewModel.isLock { return }
                                if self.viewModel.isSeekAble == false { return }
                                self.viewModel.request = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                            })
                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                self.uiViewChange()
                            })
                    }
                    ZStack{
                        if let seek = self.seekForward {
                            CPEffect(
                                icon: Asset.component.player.forward,
                                text: seek.description,
                                isReverse: true)
                        }
                        Spacer().modifier(MatchParent())
                            .background(Color.transparent.clearUi)
                            .onTapGesture(count: 2, perform: {
                                if !self.useSeekingUi { return }
                                if self.viewModel.isLock { return }
                                if self.viewModel.isSeekAble == false { return }
                                self.viewModel.request = .seekForward(self.viewModel.getSeekForwardAmount(), isUser: true)
                            })
                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                self.uiViewChange()
                            })
                    }
                }
                .accessibilityElement()
                .accessibility(label: Text("Player"))
                .accessibilityAction{
                    self.uiViewChange()
                }
                .opacity(self.useUi ? 1 : 0)
                
                self.ui
                if !self.useUi {
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.clearUi)
                        .onTapGesture(count: 1, perform: {
                            self.viewModel.playerUiRequest = .screenTap
                        })
                }
           }
            
        }
        .onReceive(self.viewModel.$isPlay) { _ in
            self.autoUiHidden.cancel()
        }
        .onReceive(self.viewModel.$request) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .usePip(let use) :
                self.uiModel.usePip = use
            case .seekForward(let seek, _, _, _) :
                
                switch self.viewModel.playerUiStatus {
                case .hidden :
                    self.uiModel.seekForward = seek.toInt()
                default : break
                }
                
                self.delayAutoResetSeekMove()
            case .seekBackword(let seek, _, _, _) :
                switch self.viewModel.playerUiStatus {
                case .hidden :
                    self.uiModel.seekBackward = seek.toInt()
                default : break
                }
                
                self.delayAutoResetSeekMove()
            
            default : break
            }
        }
        .onReceive(self.viewModel.$screenOpercity) { opercity in
            if self.screenOpecity == opercity {return}
            withAnimation(.easeOut(duration: 1)){
                self.screenOpecity = opercity
            }
            if !self.viewModel.isMute {
                self.viewModel.request = .movePlayerVolume(Float(opercity))
            }
        }
        .onReceive(self.viewModel.$playerUiRequest) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .delayUiStatus:
                self.viewModel.playerUiStatus = .view
                self.delayAutoUiHidden()
                
            case .fixUiStatus(let isFix):
                if isFix {
                    self.autoUiHidden.cancel()
                } else {
                    self.delayAutoUiHidden()
                }
            case .viewProgressStatus(let view) :
                if !view {
                    self.viewModel.playerUiStatus = .hidden
                    self.clearAutoUiHidden()
                }
            default : break
            }
        }
        .onReceive(self.viewModel.$duration) { t in
            self.uiModel.duration = t.secToHourString()
        }
        .onReceive(self.viewModel.$playMode) { mode in
            self.sectionPlayModel.isSectionPlay = mode == .section
        }
        .onReceive(self.viewModel.$time) { t in
            if self.uiModel.isSeeking {return}
            self.uiModel.time = t.secToHourString()
            self.uiModel.progress = self.viewModel.playTimeRate
            self.uiModel.completeTime = self.viewModel.remainingTime.secToHourString()
            if self.sectionPlayModel.isSectionPlay { self.onSectionPlay(t) }
            if (Int(round(t)) % 20) == 0 {
                if UIScreen.screens.count > 1 { return }
                if UIScreen.main.isCaptured {
                    self.viewModel.request = .pause(isUser: false)
                }
            }
        }
        
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view :
                    self.delayAutoUiHidden()
                    
                default :
                    self.autoUiHidden.cancel()
                }
            }
        }
        
        .onReceive(self.viewModel.$isSeekAble) { able in
            self.setRemoteActionSeekAble()
        }
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view :
                    self.uiModel.isShowing = true
                default :
                    self.uiModel.isShowing = false
                    if self.viewModel.streamStatus == .buffering(0) { self.uiModel.isLoading = true }
                }
            }
        }
        .onReceive(self.viewModel.$seekingProgress) { pro in
            self.autoUiHidden.cancel()
            if self.uiModel.progress == pro {return}
            if self.viewModel.isLiveStream {return}
            self.uiModel.progress = pro
            if pro > 0 {
                if !self.uiModel.isSeeking {
                    self.uiModel.isSeeking = true
                }
            }
        }
        .onReceive(self.viewModel.$seeking) { seek in
            if seek == 0 {return}
            let diff = seek - self.viewModel.time
            if diff == 0 {
                self.uiModel.willTime = ""
                return
            }
            self.uiModel.willTime = ( diff>0 ? "+" : "-" ) + abs(diff).secToMinString()
            
        }
        .onReceive(self.viewModel.$error) { err in
            guard let err = err else { return }
            var msg = ""
            var code = ""
            switch err {
            case .connect(let s):
                msg = s
                code = "#connect error"
            case .stream(let err):
                switch err {
                case .playbackSection : return
                default : break
                }
                msg = err.getDescription()
                code = "#stream error"
                
            case .drm(let err):
                msg = err.getDescription()
                code = "#drm error"
            case .asset(let err):
                msg = err.getDescription()
                code = "#asset error"
            case .illegalState(_):
                return
            }
            self.uiModel.errorMessage = msg
            self.uiModel.isError = true
            
            ComponentLog.e(code + " : " + msg, tag:self.tag)
            
        }
        .onReceive(self.viewModel.$artImage) { imgPath in
            guard let img = imgPath else {return}
            if !self.useRemotePlayer {return}
            self.imageLoader.load(url: img, id: self.tag)
        }
        .onReceive(self.imageLoader.$event) { evt in
            guard let  evt = evt else { return }
            switch evt {
            case .asyncComplete(let img, let id) :
                if id != self.tag {return}
                self.updateArtwork(imageData: img)
            default : break
            }
        }
        .onReceive(self.viewModel.$request) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .load :
                self.sectionPlayEnd()
                self.uiModel.reset()
                self.uiModel.usePip = self.viewModel.usePip
                
            case .seekForward(let seek, _, _, _) :
                self.uiModel.seekForward = seek.toInt()
                self.uiModel.seekBackward = nil
                if !self.uiModel.isShowing {
                    withAnimation{
                        self.seekForward = seek.toInt()
                        self.seekBackward = nil
                    }
                }
                self.delayAutoResetSeekMove()
            case .seekBackword(let seek, _, _, _) :
                self.uiModel.seekBackward = seek.toInt()
                self.uiModel.seekForward = nil
                if !self.uiModel.isShowing {
                    withAnimation{
                        self.seekBackward = seek.toInt()
                        self.seekForward = nil
                    }
                }
                self.delayAutoResetSeekMove()
            default : break
            }
        }
        .onReceive(self.viewModel.$playerUiRequest) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .sectionPlay(let sections, _) :
                self.setSectionPlay(sections)
            case .sectionMove(let idx) :
                self.sectionMove(idx)
            case .sectionPlayEnd :
                self.sectionPlayEnd()
                
            case .timeView(let start, let end) :
                self.uiModel.startTime = start
                self.uiModel.endTime = end
            case .timeRange(let start, let end, _ , let isLiveStream) :
                self.uiModel.isVodLive = !isLiveStream
                self.uiModel.isLive = true
                self.viewModel.setLiveTime(start: start, end: end)
                
            case .viewProgressStatus(let view) :
                self.uiModel.isProgressShowing = view
            
            default : break
            }
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .loaded:
                self.delayAutoUiHidden()
                self.setRemoteActionSeekAble()
                self.uiModel.willTime = ""
                self.uiModel.isSeeking = false
            case .paused:
                self.delayAutoUiHidden()
            case .resumed:
                self.delayAutoUiHidden()
            case .seeked:
                self.uiModel.isSeeking = false
                self.delayAutoUiHidden()
            case .completed :
                if self.viewModel.isReplay {
                    self.viewModel.request = .seekTime(0, true, isUser: false)
                }
            default : break
            }
        }
        .onReceive(self.viewModel.$streamStatus) { st in
            guard let status = st else { return }
            switch status {
                case .buffering(_) : self.uiModel.isLoading = true
            default : self.uiModel.isLoading = false 
            }
        }
        .onReceive(self.viewModel.$volume){ v in
            if self.viewModel.isMute {
                self.uiModel.isSoundOn = false
            } else {
                self.uiModel.isSoundOn = v > 0
            }
        }
        .onReceive(self.viewModel.$isMute){ isMute in
            self.uiModel.isSoundOn = !isMute
        }
        .background(Color.black)
        .onAppear(){
            self.viewModel.onAppear()
            self.setRemoteAction()
        }
        .onDisappear(){
            self.viewModel.onDisappear()
            self.clearAutoUiHidden()
        }
        
    }
    

    @State var screenOpecity:Double = 1
    @State var isSeekAble:Bool = true
    func uiViewChange(){
        if self.viewModel.playerUiStatus != .view {
            self.viewModel.playerUiStatus = .view
            
        }else {
            self.viewModel.playerUiStatus = .hidden
        }
    }
    

    @StateObject private var autoUiHidden = ScheduleExcutor()
    private func delayAutoUiHidden(){
        self.autoUiHidden.cancel()
        if UIAccessibility.isVoiceOverRunning {return}
        self.autoUiHidden.reservation(delay: 2){
            self.viewModel.playerUiStatus = .hidden
            self.clearAutoUiHidden()
        }
    }
    private func clearAutoUiHidden() {
        self.autoUiHidden.cancel()
    }
    

    @State private var seekForward:Int? = nil
    @State private var seekBackward:Int? = nil
    @StateObject private var autoResetSeekMove = ScheduleExcutor()
    private func delayAutoResetSeekMove(){
        self.autoResetSeekMove.reservation(delay: 1){
            self.uiModel.seekForward = nil
            self.uiModel.seekBackward = nil
            withAnimation{
                self.seekForward = nil
                self.seekBackward = nil
            }
        }
    }
    
    
    @StateObject var sectionPlayModel:SectionPlayModel = SectionPlayModel()
    class SectionPlayModel:ObservableObject{
        var isSectionPlay = false
        var progressSections:[ProgressSection]? = nil
        var sections:[(Double,Double)] = []
        var sectionIdx:Int = 0
        var isSectionLoading = false
    }
}


