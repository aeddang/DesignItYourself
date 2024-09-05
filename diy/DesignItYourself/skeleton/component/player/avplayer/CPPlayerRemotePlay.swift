//
//  CPPlayerUI.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2023/07/31.
//

import Foundation
import SwiftUI
import Combine
import MediaPlayer

extension CPPlayer {
    func setRemoteAction(){
        if !self.useRemotePlayer {return}
        ComponentLog.d("setRemoteAction " + self.isSeekAble.description, tag:"commandCenter")
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.togglePlayPauseCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.viewModel.request = .togglePlay(isUser: true)
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.viewModel.request = .seekMove(-15, nil, isUser: true)
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.skipForwardCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.viewModel.request = .seekMove(15, nil, isUser: true)
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            let seconds = (commandEvent as? MPChangePlaybackPositionCommandEvent)?.positionTime ?? 0
            self.viewModel.request = .seekTime(seconds, isUser: true)
            return MPRemoteCommandHandlerStatus.success
        }
        
    }
    
    func setRemoteActionSeekAble(){
        if !self.useRemotePlayer {return}
        self.isSeekAble = self.viewModel.isSeekAble ?? true
        ComponentLog.d("self.isSeekAble " + self.isSeekAble.description, tag:"commandCenter")
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.changePlaybackPositionCommand.isEnabled = self.isSeekAble
        commandCenter.togglePlayPauseCommand.isEnabled = self.isSeekAble
        commandCenter.skipBackwardCommand.isEnabled = self.isSeekAble
        commandCenter.skipForwardCommand.isEnabled = self.isSeekAble
        commandCenter.seekForwardCommand.isEnabled = self.isSeekAble
        commandCenter.seekBackwardCommand.isEnabled = self.isSeekAble
    }
    
    
    func updateArtwork(imageData:UIImage) {
        if !self.useRemotePlayer {return}
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else {return}
        ComponentLog.d("updateArtwork", tag:"MPNowPlayingInfo")
        let artwork = MPMediaItemArtwork(boundsSize:.init(width: 240, height: 240)) { sz in
            return imageData
        }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}
