//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct ProgressSection:Identifiable{
    var id:String = UUID().uuidString
    let pct:CGFloat
    var color:Color = Color.transparent.clearUi
}

struct ProgressSlider: PageView {
    var progress: Float // or some value binded
    var progressSections:[ProgressSection]? = nil
    var useGesture:Bool = true
    var progressHeight:CGFloat = Dimen.bar.light
    var thumbSize:CGFloat = 10
    var thumbColor:Color = Color.brand.primary
    var color:Color = Color.brand.primary
    var bgColor:Color = Color.app.gray.opacity(0.15)
    var radius:CGFloat = Dimen.radius.micro
    var alignment:Alignment = .center
    
    var thumbImageDuration:Double = 0
    var thumbImagePath:String? = nil
    var thumbImageSize:CGSize = .init(width: 160, height: 90)
    
    var onChange: ((Float) -> Void)? = nil
    var onChanged: ((Float) -> Void)? = nil
    
   
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: self.alignment) {
                Spacer().modifier(MatchParent())
                ZStack(alignment: .leading) {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(self.bgColor)
                            .frame(
                                width: geometry.size.width,
                                height: progressHeight
                            )
                        
                        
                        Rectangle()
                            .foregroundColor(self.color)
                            .frame(
                                width: geometry.size.width * CGFloat(min(1,max(self.progress,0))),
                                height: progressHeight
                            )
                        if let sections = self.progressSections {
                            HStack(spacing: 0){
                                ForEach(sections) { section in
                                    Spacer().modifier(MatchVertical(width: geometry.size.width * section.pct))
                                        .background(section.color)
                                }
                            }
                            .frame(
                                width: geometry.size.width,
                                height: progressHeight
                            )
                        }
                        Rectangle()
                            .foregroundColor(Color.app.white)
                            .opacity(self.dragOpacity)
                            .frame(
                                width: geometry.size.width * CGFloat(self.drag),
                                height: progressHeight)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: self.radius))
                    if self.thumbSize > 0 {
                        if self.isThumbDrag, let path = self.thumbImagePath {
                            ImageGridView(
                                url: path,
                                imageSize: self.thumbImageSize,
                                index: self.thumbImageIndex
                            )
                            .offset(x:self.thumbOffsetX, y:self.thumbOffsetY)
                            .frame(width: 0, height: 0)
                            
                        }
                        Circle()
                            .foregroundColor(self.thumbColor)
                            .frame(width: self.thumbSize, height: self.thumbSize)
                            .offset( x: self.getThumbPosition(geometry:geometry))
                            .frame(width: 0, height: 0)
                    }
                }
                .frame(height: progressHeight)
            }
            .modifier(MatchParent())
            .background(Color.transparent.clearUi)
            .highPriorityGesture(DragGesture(minimumDistance: 20)
                .onChanged({ value in
                    if !useGesture { return }
                    self.isThumbDrag = true
                    let screenWidth = geometry.size.width
                    let d = min(max(0, Float(value.location.x / screenWidth)), 1)
                    self.drag = d
                    self.dragOpacity = 0.3
                    if let change = self.onChange {
                        change(self.drag)
                    }
                    if self.thumbImagePath?.isEmpty == false {
                        let minPos:CGFloat = self.thumbImageSize.width/2
                        let maxPos = screenWidth - minPos
                        let pos = screenWidth * CGFloat(d)
                        self.thumbOffsetX = max(minPos,min(pos, maxPos))
                        self.thumbImageIndex = Int(round((self.thumbImageDuration * Double(d))/10.0))
                    }
                
                })
                .onEnded({ value in
                    if !useGesture { return }
                    self.onProgressCompleted()
                }))
        }
        /*
        .onAppCameToForeground {
            if self.isThumbDrag {
                onProgressCompleted()
            }
        }
        */
        .onAppWentToBackground {
            if self.isThumbDrag {
                self.onProgressCompleted()
            }
        }
        .onAppear{
            self.thumbOffsetY = -(self.thumbImageSize.height - self.thumbSize - Dimen.margin.tiny)
        }
        
    }
    @State var dragOpacity:Double = 0.0
    @State var drag: Float = 0.0
    @State var isThumbDrag: Bool = false
    @State var thumbOffsetX: CGFloat = 0
    @State var thumbOffsetY: CGFloat = 0
    @State var thumbImageIndex: Int = 0
    
    private func onProgressCompleted(){
        self.isThumbDrag = false
        if let changed = self.onChanged {
            changed(self.drag)
        }
        self.dragOpacity = 0.0
    }
    
    func getThumbPosition(geometry:GeometryProxy)->CGFloat{
        let screenWidth = geometry.size.width
        let minPos:CGFloat = self.thumbSize/2
        let maxPos = screenWidth - minPos
        var pos = screenWidth * CGFloat(self.progress)
        pos = max(minPos, min(pos,maxPos))
        return pos
    }
}
#if DEBUG
struct ProgressSlider_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ProgressSlider(
                progress:  0.5,
                thumbSize: 20,
                bgColor: Color.app.gray
            )
            .frame(width: 375, alignment: .center)
        }
    }
}
#endif
