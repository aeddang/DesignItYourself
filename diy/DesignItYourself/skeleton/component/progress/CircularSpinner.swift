//
//  CircularProgressIndicator.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct CircularSpinner: View {
    @State private var shouldAnimate = false
    
    var color = Color.brand.primary
    var size:CGFloat = Dimen.icon.medium
    var stroke:CGFloat = 7
    var body: some View {
        ZStack {
            Spacer()
                .drawStrokeCircle(
                    start: CGFloat(0),
                    end: CGFloat(270),
                    color: color, width: self.stroke)
            .modifier(MatchParent())
            .rotationEffect(.degrees( shouldAnimate ? 360 : 0 ))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: shouldAnimate)
        }
        .frame(width: self.size, height: self.size)
        .onAppear {
            self.shouldAnimate = true
        }
    }
    
}

#if DEBUG
struct CircularSpinner_Previews: PreviewProvider {
    static var previews: some View {
        CircularSpinner()
    }
}
#endif
