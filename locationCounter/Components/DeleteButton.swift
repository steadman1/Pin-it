//
//  DismissButton.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/30/22.
//

import SwiftUI

struct DeleteButton: View {
    let closure: () -> Void
    let size: Double
    
    init(closure: @escaping () -> Void, size: Double = 40) {
        self.closure = closure
        self.size = size
    }
    
    var body: some View {
        FlatTappableZStack(cornerRadius: size) {
            ZStack {
                Image(systemName: "trash")
                    .font(UILanguage.textFont.bold())
            }.frame(width: size, height: size)
            .background(Color.warning)
        } onTap: {
            closure()
        }.frame(width: size, height: size)

    }
}

extension DismissButton {
    
}
