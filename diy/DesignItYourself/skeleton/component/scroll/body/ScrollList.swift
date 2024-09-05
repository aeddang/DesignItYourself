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

struct ScrollList<Content>: PageView where Content: View {
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
    var usePullToReflash:Bool
    var useTracking:Bool
    var scrollType:InfinityScrollType = .vertical(isDragEnd: false)
    var bgColor:Color //List only
    var isAlignCenter:Bool = false
    let isRecycle: Bool
    let onReady:()->Void
    let onMove:(CGFloat)->Void
    
     
    init(
        viewModel: InfinityScrollModel,
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
        usePullToReflash:Bool,
        useTracking:Bool,
        bgColor:Color,
        onReady:@escaping ()->Void,
        onMove:@escaping (CGFloat)->Void,
        content: Content) {
        
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
        self.usePullToReflash = usePullToReflash
        self.useTracking = useTracking
        self.bgColor = bgColor
        self.onReady = onReady
        self.onMove = onMove
        self.scrollType = scrollType
    }
    var body: some View {
        Group{
            ScrollViewReader{ reader in
                if self.usePullToReflash {
                    self.getBody()
                        .refreshable {
                            self.viewModel.event = .pullCompleted
                        }
                        .onChange(of: self.scrollIdx, perform: { idx in
                            guard let idx = idx else {return}
                            if idx == -1 {return}
                            if self.isSmothMove {
                                withAnimation(.easeOut(duration: 0.2)){ reader.scrollTo(idx, anchor: anchor)}
                            } else {
                                reader.scrollTo(idx, anchor: anchor)
                            }
                            self.scrollIdx = -1
                        })
                } else {
                    self.getBody()
                        .onChange(of: self.scrollIdx, perform: { idx in
                            guard let idx = idx else {return}
                            if idx == -1 {return}
                            if self.isSmothMove {
                                withAnimation(.easeOut(duration: 0.2)){ reader.scrollTo(idx, anchor: anchor)}
                            } else {
                                reader.scrollTo(idx, anchor: anchor)
                            }
                            self.scrollIdx = -1
                        })
                }
                    
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
                case .scrollLock(let lock) :
                    self.scrollDisabled = lock
                default: break
                }
            }
        }
        .onAppear(){
            self.onReady()
        }
       
    }//body
    
    @State var anchor:UnitPoint? = nil
    @State var scrollIdx:Int? = nil
    @State var isSmothMove:Bool = false
    @State var scrollDisabled:Bool = false
    @ViewBuilder
    func getBody() -> some View {
        List{
            Spacer()
                .frame(height: self.marginTop)
                .listRowBackground(Color.transparent.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom:0, trailing: 0))
                .id(self.viewModel.topIdx)
                .onAppear(){
                    self.viewModel.event = .top
                }
            self.content
                .listRowSeparator(.hidden)
                .listRowBackground(Color.transparent.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom:self.spacing, trailing: 0))
            
            Spacer().frame(height: self.marginBottom)
                .listRowBackground(Color.transparent.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom:0, trailing: 0))
                .id(self.viewModel.bottomIdx)
                .onAppear(){
                    self.viewModel.event = .bottom
                }
        }
        .scrollDisabled(self.scrollDisabled)
        .environment(\.defaultMinListRowHeight,0)
     
        .padding(.leading, self.marginStart)
        .padding(.trailing, self.marginEnd)
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .modifier(MatchParent())
        .coordinateSpace(name: self.tag)
        .background(self.bgColor)
    }
}


