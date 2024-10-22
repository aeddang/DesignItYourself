//
//  ReflashSpinner.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/05.
//
import Foundation
import SwiftUI

struct StarRate: PageView {
    @Binding var progress:Float
    var icon:String = ""
    var iconRange:Range = .init(0...4)
    var changeUnit:Float = 0.1
    var size:CGSize = .init(width: 150, height: 28)
    var bgColor:Color = Color.brand.content
    var color:Color = Color.yellow
    var useGesture:Bool = true
    var onChange: ((Float) -> Void)? = nil
    var onChanged: ((Float) -> Void)? = nil
    var body: some View {
        ZStack(alignment: .leading){
            Spacer().modifier(MatchParent())
                .background(self.bgColor)
            Spacer().modifier(MatchVertical(width: self.size.width * CGFloat(self.progress)))
                .background(self.color)
            HStack(spacing: 0) {
                ForEach(self.iconRange, id: \.self){ idx in
                    Spacer()
                    .modifier(MatchParent())
                    .background(Color.transparent.clearUi)
                    .onTapGesture {
                        let unitProgress:Float = Float(idx+1) / Float(self.iconRange.count)
                        self.onChanged?(unitProgress)
                        withAnimation{
                            self.progress = unitProgress
                        }
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .mask(
            HStack(spacing: Dimen.margin.micro) {
                ForEach(self.iconRange, id: \.self){ idx in
                    Image(self.icon)
                        .resizable()
                        .modifier(MatchParent())
                        .onTapGesture {
                            let unitProgress:Float = Float((idx+1)) * (1.0/Float(iconRange.count))
                            self.onChanged?(unitProgress)
                            withAnimation{
                                self.progress = unitProgress
                            }
                        }
                }
            }
            .frame(width: size.width, height: size.height)
        )
        .gesture(DragGesture(minimumDistance: 20)
            .onChanged({ value in
                if !useGesture { return }
                let d = min(max(0, Float(value.location.x / self.size.width)), 1)
                self.progress = d
                self.onChange?(d)
            })
            .onEnded({ value in
                if !useGesture { return }
                let d = min(max(0, Float(value.location.x / self.size.width)), 1)
                let unitCount = round(d / self.changeUnit)
                let unitProgress = self.changeUnit * unitCount
                self.onChanged?(unitProgress)
                withAnimation{
                    self.progress = unitProgress
                }
            }))
        .onAppear(){
            
        }
    }//body
    
    
}

#if DEBUG
struct ReflashStarRate_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            StarRate(progress: .constant(0.5))
                .environmentObject(PagePresenter())
        }
    }
}
#endif

