//
//  CPPlayerSectionPlay.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2023/07/31.
//

import Foundation
extension CPPlayer{
    func setSectionPlay(_ sections:[(Double,Double)], idx:Int? = nil){
        if sections.isEmpty {
            self.sectionPlayEnd()
            return
        }
        self.sectionPlayModel.sections = sections
        self.sectionPlayModel.sectionIdx = idx ?? -1
        self.sectionPlayModel.isSectionLoading = false
        self.viewModel.setPlayMode(.section)
        PageLog.d("setSectionPlay " + sections.count.description , tag: "SectionPlay")
        
    }
    func sectionMove(_ idx:Int){
        if self.sectionPlayModel.sections.count <= idx {return}
        let willIdx = idx
        self.sectionPlayModel.sectionIdx = willIdx
        
        let sectionTime = self.sectionPlayModel.sections[willIdx].0
        self.sectionPlayModel.isSectionLoading = true
        self.viewModel.setSectionIndex(willIdx, sectionTime: sectionTime)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.viewModel.screenOpercity = 1
        }
        PageLog.d("sectionMove sectionPlayNext " + self.sectionPlayModel.sections.count.description , tag: "SectionPlay")
    }
    func sectionPlayEnd(){
        self.sectionPlayModel.sections = []
        self.sectionPlayModel.sectionIdx = -1
        self.viewModel.setPlayMode(.normal)
        PageLog.d("sectionPlayEnd " + sectionPlayModel.sections.count.description , tag: "SectionPlay")
    }
    func onSectionPlay(_ tm:Double){
    
        if self.sectionPlayModel.sectionIdx ==  -1 {
            if self.sectionPlayModel.isSectionLoading {return}
            self.sectionPlayModel.isSectionLoading = true
            let startIdx = self.sectionPlayModel.sections.firstIndex(where: {$0.0 > tm}) ?? 0
            let sectionTime = self.sectionPlayModel.sections[startIdx].0
            self.sectionPlayModel.sectionIdx = startIdx
            self.viewModel.setSectionIndex(startIdx, sectionTime: sectionTime)
            PageLog.d("onSectionPlay init sectionPlayNext " + sectionPlayModel.sections.count.description , tag: "SectionPlay")
            return
        }
        let section = self.sectionPlayModel.sections[self.sectionPlayModel.sectionIdx]
        if section.0 <= tm && section.1 > tm {
            self.sectionPlayModel.isSectionLoading = false
            let fadeIn = tm - section.0
            let fadeOut = section.1 - tm
            let check:Double = 1
            if fadeIn <= check || fadeOut <= check{
                let opc = self.viewModel.screenOpercity
                if fadeIn < check && opc != 1 {
                    self.viewModel.screenOpercity = 1
                } else if fadeOut < check && opc != 0{
                    self.viewModel.screenOpercity = 0
                }
            } else if fadeIn <= 2 {
                let opc = self.viewModel.screenOpercity
                if opc != 1 {
                    self.viewModel.screenOpercity = 1
                }
            }
            return
        } else if !self.sectionPlayModel.isSectionLoading && section.1 > tm {
            return
        }
        if self.sectionPlayModel.isSectionLoading {return}
        let willIdx = self.sectionPlayModel.sectionIdx + 1
        if willIdx >= self.sectionPlayModel.sections.count {
            self.viewModel.onSectionPlayCompleted()
            self.sectionPlayEnd()
          
        } else {
            self.sectionPlayModel.isSectionLoading = true
            let sectionTime = self.sectionPlayModel.sections[willIdx].0
            self.sectionPlayModel.sectionIdx = willIdx
            self.viewModel.setSectionIndex(willIdx, sectionTime: sectionTime, isUser: false)
            
            PageLog.d("onSectionPlay update sectionPlayNext " + self.sectionPlayModel.sections.count.description , tag: "SectionPlay")
        }
    }
}
