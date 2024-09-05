//
//  SwipperView.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
extension LoopSwipperView {
    static let duration:Double = 0.35
    static let ani:Animation = Animation.easeOut(duration: duration)
    static let aniBg:Animation = Animation.easeOut(duration: duration)
}
struct LoopSwipperView : View , PageProtocol, Swipper {
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var pages: [any PageView]
    var isForground:Bool = true
    var ratio:CGFloat = 1.0
    var action:((Int) -> Void)? = nil
    
    @State var index: Int = 0
    var body: some View { 
        GeometryReader { geometry in
            if self.pages.count <= 1 {
                self.pages.first?.contentBody
                    .frame(
                        width: geometry.size.width * ratio,
                        height: geometry.size.height * ratio,
                        alignment: .top
                    )
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                    .onTapGesture(){
                        guard let action = self.action else {return}
                        action(0)
                    }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 0) {
                        self.pages.last?.contentBody
                            .frame(
                                width: geometry.size.width * ratio,
                                height: geometry.size.height * ratio,
                                alignment: .top
                            )
                            .frame(
                                width: geometry.size.width ,
                                height: geometry.size.height
                            )
                            .clipped()
                            
                            
                        ForEach(self.pages, id:\.id)  { page in
                            page.contentBody
                                .frame(
                                    width: geometry.size.width * ratio,
                                    height: geometry.size.height * ratio,
                                    alignment: .top
                                )
                                .frame(
                                    width: geometry.size.width ,
                                    height: geometry.size.height
                                )
                                .clipped()
                            
                        }
                        self.pages.first?.contentBody
                            .frame(
                                width: geometry.size.width * ratio,
                                height: geometry.size.height * ratio,
                                alignment: .top
                            )
                            .frame(
                                width: geometry.size.width ,
                                height: geometry.size.height
                            )
                            .clipped()
                            
                           
                    }
                }
                .content
                .offset(x: self.isUserSwiping ? self.offset : CGFloat(self.index + 1) * -geometry.size.width)
                .frame(width: geometry.size.width, alignment: .topLeading)
                //.clipped()
                .onTapGesture(){
                    guard let action = self.action else {return}
                    action(self.index)
                }
                .highPriorityGesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged({ value in
                        if !self.isForground { return }
                        self.isUserSwiping = true
                        if self.viewModel.pagerStatus == .stop {
                            self.viewModel.pagerStatus = .move
                            self.dragOffset = value.translation.width
                        }
                        self.offset = self.getDragOffset(value: value, geometry: geometry, offset: self.dragOffset) - geometry.size.width
                        self.viewModel.request = .drag(self.offset)
                        self.autoReset()
                    })
                    .onEnded({ value in
                        if !self.isForground { return }
                        let willIdx = self.getWillIndex(value: value, minIdx: -1, maxIdx: self.pages.count + 1)
                        self.reset(idx: willIdx)
                        
                    })
                )
                .gesture(
                    LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
                          .simultaneously(with: RotationGesture(minimumAngleDelta:.zero))
                          .simultaneously(with: MagnificationGesture(minimumScaleDelta: 0))
                        .onChanged({_ in
                            if !self.isForground { return }
                            self.reset(idx: self.index)
                        })
                        .onEnded({_ in
                            if !self.isForground { return }
                            self.reset(idx: self.index)
                        })
                )
                .onAppear(){
                    DispatchQueue.main.async {
                        self.index = self.viewModel.index ?? 0
                    }
                }
                .onDisappear(){
                    self.autoResetSubscription?.cancel()
                    self.autoResetSubscription = nil
                }
            }
            
         }//GeometryReader
    }//body
    @State var dragOffset:CGFloat = 0
    @State var offset: CGFloat = 0
    @State var isUserSwiping: Bool = false
   
    func reset(idx:Int) {
        self.autoResetSubscription?.cancel()
        self.autoResetSubscription = nil
        if !self.isUserSwiping {
            self.viewModel.pagerStatus = .stop
            return
        }
        
        if self.viewModel.pagerStatus == .stop { self.viewModel.pagerStatus = .move }
        DispatchQueue.main.async {
            if self.viewModel.index != idx { self.viewModel.index = idx }
            withAnimation(self.isForground ? Self.ani : Self.aniBg){
               self.isUserSwiping = false
               if idx != self.index {
                   self.index = idx
               } else {
                   self.viewModel.request = .draged
               }
           }
        }
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + Self.duration) {
            DispatchQueue.main.async {
                let min = 0
                let max = self.pages.count-1
                if self.index < min {
                    self.index = max
                } else  if self.index > max {
                    self.index = min
                }
                
                self.viewModel.pagerStatus = .stop
                if self.viewModel.index != self.index { self.viewModel.index = self.index }
            }
        }
        
     }
    
    @State var autoResetSubscription:AnyCancellable?
    func autoReset() {
        //self.autoResetSubscription = self.creatResetTimer()
    }
}


