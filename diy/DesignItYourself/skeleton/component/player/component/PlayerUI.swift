//
//  PlayerUI.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import MediaPlayer
import AVKit
extension PlayerUI {
    static let paddingFull = Dimen.margin.thin 
    static let padding = Dimen.margin.tiny
    static let uiHeight:CGFloat = 48
    static let uiRealHeight:CGFloat = 34
    static let timeTextWidth:CGFloat  = 48
    static let spacing:CGFloat = Dimen.margin.thin
    static let bottomMargin:CGFloat = 60
}
struct PlayerUI: PageView {
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var uiModel:PlayerUIModel
    
    var isStaticUiShow:Bool = true
    var useProgress:Bool = true
    var bottomMargin:CGFloat = Dimen.margin.regular
   
    var body: some View {
        ZStack{
            if self.isStaticUiShow {
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.clearUi)
                    .onTapGesture(count: 1, perform: {
                        self.viewModel.playerUiRequest = .screenTap
                    })
            } else {
                HStack(spacing:0){
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.clearUi)
                        .onTapGesture(count: 2, perform: {
                            if self.viewModel.isLock { return }
                            if !self.isSeekAble { return }
                            self.viewModel.request = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                        })
                        .onTapGesture(count: 1, perform: {
                            self.viewModel.playerUiStatus = .hidden
                        })
                        .accessibilityElement()
                        .accessibility(label: Text("seeking to back"))
                        .accessibilityAction {
                            if self.viewModel.isLock { return }
                            if !self.isSeekAble { return }
                            self.viewModel.request = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                        }
                    
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.clearUi)
                        .onTapGesture(count: 2, perform: {
                            if self.viewModel.isLock { return }
                            if !self.isSeekAble { return }
                            self.viewModel.request = .seekForward(self.viewModel.getSeekForwardAmount(), isUser: true)
                        })
                        .onTapGesture(count: 1, perform: {
                            self.viewModel.playerUiStatus = .hidden
                        })
                        .accessibilityElement()
                        .accessibility(label: Text("seeking to forword"))
                        .accessibilityAction {
                            if self.viewModel.isLock { return }
                            if !self.isSeekAble { return }
                            self.viewModel.request = .seekForward(self.viewModel.getSeekForwardAmount(), isUser: true)
                        }
                }
                .padding(.vertical, Dimen.tab.regular)
                .background(Color.transparent.black50)
                .opacity(self.isShowing ? 1 : 0)
                .accessibility(hidden: !self.isShowing)
            }

            HStack(spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                ZStack{
                    if self.isSeekAble {
                        Text((self.seekBackward ?? 10).description)
                            .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.app.white))
                            .padding(.top, 6)
                    }
                    ImageButton(
                        defaultImage: Asset.component.player.seekBackward,
                        size: CGSize(width:Dimen.icon.medium,height:Dimen.icon.medium)
                    
                    ){ _ in
                        if self.viewModel.streamStatus != .playing {return}
                        let value = self.viewModel.getSeekBackwordAmount()
                        self.viewModel.request = .seekBackword(value, isUser: true)
                    }
                    .accessibility(label: Text("seeking to back"))
                    .opacity(self.isSeekAble ? 1 : 0)
                    .rotationEffect(.degrees(self.isControlAble ? 0 : 90))
                }
                .opacity(self.isSeeking ? 0 : 1)
                Spacer().modifier(MatchHorizontal(height: 0))
                VStack(spacing:Dimen.margin.regular){
                    if !self.isSeeking {
                        ImageButton(
                            isSelected: self.isPlaying,
                            defaultImage: Asset.component.player.resume,
                            activeImage: Asset.component.player.pause,
                            size: CGSize(width:Dimen.icon.heavy,height:Dimen.icon.heavy)
                        
                        ){ _ in
                            self.viewModel.isUserPlay = self.isPlaying ? false  : true
                            if !self.viewModel.isResumeAble && !self.isPlaying {
                                self.viewModel.request = .resumeDisable(isUser: true)
                                return
                            }
                            self.viewModel.request = .togglePlay(isUser: true)
                        }
                        .accessibility(label: Text(
                            self.isPlaying ? "pause" :  "resume"))
                    } else {
                        Text(self.willTime)
                            .modifier(BoldTextStyle(size:  Font.size.bold, color: Color.app.white))
                            .frame(width:82, height: Dimen.icon.heavy, alignment: .leading)
                            .padding(.bottom, self.isSeeking ? Dimen.margin.medium : 0)
                    }

                }
                .opacity(self.isLoading ? 0 : 1)
                .accessibility(hidden: !self.isControlAble)
                
                Spacer().modifier(MatchHorizontal(height: 0))
                ZStack{
                    if self.isSeekAble {
                        Text((self.seekForward ?? 10).description)
                            .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.app.white))
                            .padding(.top, 6)
                    }
                    ImageButton(
                        defaultImage: Asset.component.player.seekForward,
                        size: CGSize(width:Dimen.icon.medium,height:Dimen.icon.medium)
                    
                    ){ _ in
                        if self.viewModel.streamStatus != .playing {return}
                        let value = self.viewModel.getSeekForwardAmount()
                        self.viewModel.request = .seekForward(value, isUser: true)
                    }
                    .accessibility(label: Text("seeking to forward"))
                    .opacity(self.isSeekAble ? 1 : 0)
                    .rotationEffect(.degrees(self.isControlAble ? 0 : -90))
                }
                .opacity(self.isSeeking ? 0 : 1)
                Spacer().modifier(MatchHorizontal(height: 0))
            }
            .opacity( self.isControlAble ? 1 : 0 )
            
            VStack(spacing:0){
                Spacer()
                HStack(alignment:.center, spacing:Self.spacing){
                    Text(self.startTime ?? self.time)
                        .kerning(Font.kern.thin)
                        .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.app.white))
                        .lineLimit(1)
                        .frame(width:Self.timeTextWidth)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibility(label:Text("time" + self.time))
                    
                    ProgressSlider(
                        progress: self.progress,
                        progressSections: self.isSectionPlay ? nil :self.progressSections,
                        useGesture: self.isSeekAble,
                        thumbSize: self.isSeekAble ? Dimen.icon.tiny : 0,
                        thumbColor: Color.app.white,
                        color: self.isSectionPlay ? Color.app.gray : self.progressColor,
                        thumbImageDuration: self.viewModel.duration,
                        thumbImagePath: self.viewModel.thumbImagePath,
                        onChange: { pct in
                            self.viewModel.searching(pct: pct)
                        },
                        onChanged:{ pct in
                            self.viewModel.request = .seekProgress(pct, isUser: true)
                        })
                    .frame(height: Self.uiHeight)
                    .accessibilityElement()
                    .accessibility(label:Text("time" + self.time))
                    
                    Text(self.endTime ?? self.completeTime)
                        .kerning(Font.kern.thin)
                        .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.app.white))
                        .lineLimit(1)
                        .frame(width:Self.timeTextWidth)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibility(label:Text("end time" + self.completeTime))
                    
                    ImageButton(
                        defaultImage: Asset.component.player.fullScreenOff,
                        activeImage: Asset.component.player.fullScreenOn,
                        size: CGSize(width:Dimen.icon.regular,height:Dimen.icon.regular)
                    
                    ){ _ in
                        self.viewModel.playerUiRequest = .fullScreen(true, isUser: true)
                    }
                    
                }
                .padding(.horizontal, Self.paddingFull)
                .padding(.bottom, self.bottomMargin)
            }
            .opacity(self.isStaticUiShow
                     ? 1
                     : self.isShowing && !self.viewModel.isLock ? 1 : 0)
            .opacity(self.isProgressShowing ? 1 : 0)
            .accessibility(hidden: !self.isShowing)
        }
        .onReceive(self.viewModel.$isSeekAble) { able in
            guard let able = able else {return}
            self.isSeekAble = able
            let isResumeAble = self.isSectionPlay ? true : able
            self.viewModel.isResumeAble = isResumeAble
        }
        .onReceive(self.viewModel.$isPlay) { play in
            self.isPlaying = play
        }
        .onReceive(self.uiModel.$isLive) { isLive in
            self.isLive = isLive
        }
        .onReceive(self.viewModel.$progressSections){ sections in
            self.progressSections = sections
        }
        .onReceive(self.viewModel.$progressColor){ color in
            self.progressColor = color
        }
        .onReceive(self.viewModel.$isPlay){isPlay in
            self.isPlaying = isPlay
        }
        .onReceive(self.viewModel.$playMode){mode in
            withAnimation{self.isSectionPlay = mode == .section}
        }
        .onReceive(self.uiModel.$duration){d in
            self.duration = d
        }
        .onReceive(self.uiModel.$time){t in
            self.time = t
        }
        .onReceive(self.uiModel.$willTime){t in
            self.willTime = t
        }
        .onReceive(self.uiModel.$completeTime){t in
            self.completeTime = "-" + t
        }
        .onReceive(self.uiModel.$startTime){t in
            self.startTime = t
        }
        .onReceive(self.uiModel.$endTime){t in
            self.endTime = t
        }
        .onReceive(self.uiModel.$progress){p in
            self.progress = p
        }
        .onReceive(self.uiModel.$isLoading){isLoading in
            withAnimation{ self.isLoading = isLoading }
        }
        .onReceive(self.uiModel.$isError){isError in
            self.errorMessage = self.uiModel.errorMessage ?? ""
            withAnimation{ self.isError = isError }
        }
        .onReceive(self.uiModel.$isSoundOn){isSoundOn in
            self.isSoundOn = isSoundOn
        }
        .onReceive(self.uiModel.$isShowing){isShowing in
            withAnimation{ self.isShowing = isShowing }
        }
        .onReceive(self.uiModel.$isSeeking){isSeeking in
            withAnimation{ self.isSeeking = isSeeking }
        }
        .onReceive(self.uiModel.$isProgressShowing){isShowing in
            withAnimation{ self.isProgressShowing = isShowing }
        }
        .onReceive(self.uiModel.$seekForward){seekForward in
            withAnimation{ self.seekForward = seekForward }
        }
        .onReceive(self.uiModel.$seekBackward){seekBackward in
            withAnimation{ self.seekBackward = seekBackward }
        }
    }
    
    @State var time:String = "00:00:00"
    @State var completeTime:String = "00:00:00"
    @State var duration:String = "00:00:00"
    @State var willTime:String = "00:00"
    @State var progress: Float = 0
    
    @State var isLive:Bool = false
    @State var isPlaying = false
    @State var isLoading = false
    @State var isError = false
    @State var isSoundOn = true
    @State var isShowing: Bool = false
    @State var errorMessage = ""
   
    @State var startTime:String? = nil
    @State var endTime:String? = nil
    
    @State var isSectionPlay = false
    @State var isProgressShowing: Bool = false
    @State var progressSections:[ProgressSection]? = nil
    @State var progressColor:Color = Color.brand.primary
    
    @State var isSeeking = false
    @State var isSeekAble = false
    @State var seekForward:Int? = nil
    @State var seekBackward:Int? = nil
    
    private var isControlAble:Bool {
        get{
            return self.isShowing && !self.viewModel.isLock
        }
    }
    
    
}

