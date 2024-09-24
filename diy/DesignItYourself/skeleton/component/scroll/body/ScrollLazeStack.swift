//
//  InfinityScrollView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/25.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct ScrollLazeStack<Content>: PageView where Content: View {
    var viewModel: InfinityScrollModel
    let axes: Axis.Set
    let showIndicators: Bool
    let content: Content
    var contentSize: CGFloat = -1
    var header:(any PageView)? = nil
    var headerSize: CGFloat = 0
    var marginTop: CGFloat
    var marginBottom: CGFloat
    var marginStart: CGFloat
    var marginEnd: CGFloat
    var spacing: CGFloat
    var useTracking:Bool
    var usePullToReflash:Bool
    var scrollType:InfinityScrollType = .vertical(isDragEnd: false)
    var isAlignCenter:Bool = false
    let isRecycle: Bool
    let onReady:()->Void
    let onMove:(CGFloat)->Void
    
    @State var scrollIdx:Int? = nil
    @State var isTracking = false
    @State var anchor:UnitPoint? = nil
    @State var isSmothMove:Bool = false
    @State var progress:Double = 1
    @State var progressMax:Double = 1
 
    init(
        viewModel:InfinityScrollModel,
        axes: Axis.Set,
        scrollType:InfinityScrollType,
        showIndicators: Bool,
        contentSize : CGFloat,
        header:(any PageView)?,
        headerSize: CGFloat,
        marginTop: CGFloat,
        marginBottom: CGFloat,
        marginStart: CGFloat,
        marginEnd: CGFloat,
        isAlignCenter:Bool,
        spacing: CGFloat,
        isRecycle:Bool,
        useTracking:Bool,
        usePullToReflash:Bool,
        onReady:@escaping ()->Void,
        onMove:@escaping (CGFloat)->Void,
        content:Content) {
        
        self.viewModel = viewModel
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content
        self.header = header
        self.headerSize = header != nil ? headerSize : 0
        self.contentSize = contentSize
        self.marginTop = marginTop
        self.marginBottom = marginBottom
        self.marginStart = marginStart
        self.marginEnd = marginEnd
        self.isAlignCenter = isAlignCenter
        self.spacing = spacing
        self.isRecycle = isRecycle
        self.useTracking = useTracking
        self.usePullToReflash = usePullToReflash
        self.onReady = onReady
        self.onMove = onMove
        self.scrollType = scrollType 
    }
        
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollViewReader{ reader in
                Group{
                    if self.usePullToReflash {
                        ScrollView(
                            self.axes ,
                            showsIndicators: self.axes == .vertical ? self.showIndicators : false) {
                            self.getBody()
                        }
                        .refreshable {
                            self.viewModel.event = .pullCompleted
                        }
                    } else {
                        ScrollView(
                            self.axes ,
                            showsIndicators: self.axes == .vertical ? self.showIndicators : false) {
                            self.getBody()
                        }
                    }
                }
                .coordinateSpace(name: self.tag)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.onPreferenceChange(value: value)
                }
                .onChange(of: self.scrollIdx){
                    guard let idx =  self.scrollIdx else {return}
                    if idx == -1 {return}
                    if self.isSmothMove {
                        withAnimation(.easeOut(duration: 0.2)){ reader.scrollTo(idx, anchor: anchor)}
                    } else {
                        reader.scrollTo(idx, anchor: anchor)
                    }
                    self.scrollIdx = -1
                }
                .onReceive(self.viewModel.$uiEvent){ evt in
                    guard let evt = evt else{ return }
                    switch evt {
                    case .scrollTo(let idx, let anchor):
                        self.anchor = anchor
                        self.isSmothMove = false
                        self.scrollIdx = idx
                    case .scrollMove(let idx, let anchor):
                        self.anchor = anchor
                        self.isSmothMove = true
                        self.scrollIdx = idx
                    default: break
                    }
                }
                .onAppear(){
    
                    self.isTracking = true
                    self.onReady()
                    self.initMove()
                }
                .onDisappear{
                    self.isTracking = false
                }
            }
        }//available
    }//body
    private func initMove(){
        
    }
    private func onPreferenceChange(value:[CGFloat]){
        if !self.useTracking {return}
        let contentOffset = value[0]
        self.onMove(contentOffset)
    }
    
    private func calculateContentOffset(insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return insideProxy.frame(in: .named(self.tag)).minY
        } else {
            return insideProxy.frame(in: .named(self.tag)).minX
        }
    }
    
    @ViewBuilder
    func getBody() -> some View {
        
        if self.axes == .vertical {
            ZStack(alignment: self.isAlignCenter ? .top : .topLeading){
                if self.useTracking {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
                    }
                }
                if self.isRecycle {
                    LazyVStack(alignment: self.isAlignCenter ? .center : .leading, spacing: self.spacing, pinnedViews: [.sectionHeaders]){
                        self.content
                        
                        Spacer().frame(
                            height: self.marginBottom)
                            .listRowBackground(Color.transparent.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom:0, trailing: 0))
                            .id(self.viewModel.bottomIdx)
                            .onAppear(){
                                self.viewModel.event = .bottom
                            }
                    }
                    .padding(.top, self.marginTop + self.headerSize)
                    .padding(.leading, self.marginStart)
                    .padding(.trailing, self.marginEnd)
                    
                    
                } else {
                    VStack(alignment: self.isAlignCenter ? .center : .leading, spacing: self.spacing){
                        self.content
                    }
                    .padding(.top, self.marginTop + self.headerSize)
                    .padding(.bottom, self.marginBottom)
                    .padding(.leading, self.marginStart)
                    .padding(.trailing, self.marginEnd)
                }
                if let header = self.header {
                    header.contentBody
                        .padding(.top, self.marginTop)
                }
                Spacer()
                    .modifier(MatchHorizontal(height: 1))
                    .background(Color.transparent.clearUi)
                    .id(self.viewModel.topIdx)
            }
            .modifier(MatchParent())
            .frame(alignment: .topLeading)
            
            //.drawingGroup()
        } else {
            ZStack (alignment: self.isAlignCenter ? .leading : .topLeading) {
                if self.useTracking {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(insideProxy: insideProxy)])
                    }
                }
                if self.isRecycle {
                    LazyHStack (alignment: self.isAlignCenter ? .center : .top, spacing: self.spacing){
                        self.content
                    }
                    .padding(.top, self.marginTop + self.headerSize)
                    .padding(.bottom, self.marginBottom)
                    .padding(.leading, self.marginStart + self.headerSize)
                    .padding(.trailing, self.marginEnd)
                    
                } else {
                    HStack (alignment: self.isAlignCenter ? .center : .top, spacing: self.spacing){
                        self.content
                    }
                    .padding(.top, self.marginTop)
                    .padding(.bottom, self.marginBottom)
                    .padding(.leading, self.marginStart + self.headerSize)
                    .padding(.trailing, self.marginEnd)
                }
                if let header = self.header {
                    header.contentBody
                        .padding(.leading, self.marginStart)
                        
                }
            }
            .frame(alignment: .topLeading)
            .drawingGroup()
        }
    }
}


