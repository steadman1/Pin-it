//
//  DismissButton.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/30/22.
//

import SwiftUI

struct ShareButton: View {
    let size: Double
    
    let extraCode: () -> Void
    
    init(size: Double = 40, extraCode: @escaping () -> Void) {
        self.size = size
        self.extraCode = extraCode
    }
    
    var body: some View {
        FlatTappableZStack(cornerRadius: size) {
            ZStack {
                Image(systemName: "square.and.arrow.up").font(Font.body.weight(.bold))
            }.frame(width: size, height: size)
                .background(Color.confirm)
        } onTap: {
            extraCode()
        }.frame(width: size, height: size)

    }
}
