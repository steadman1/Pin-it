//
//  DismissButton.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/30/22.
//

import SwiftUI

struct DismissButton: View {
    @StateObject var settingsValues = SettingsValues.shared
    
    @Binding var boolDismissal: Bool
    let dismissal: DismissAction?
    let size: Double
    
    let extraCode: () -> Void
    
    init(dismissal: DismissAction, size: Double = 40, extraCode: @escaping () -> Void) {
        self._boolDismissal = Binding.constant(false)
        self.dismissal = dismissal
        self.size = size
        self.extraCode = extraCode
    }
    
    init(boolDismissal: Binding<Bool>, size: Double = 40, extraCode: @escaping () -> Void) {
        self._boolDismissal = boolDismissal
        self.dismissal = nil
        self.size = size
        self.extraCode = extraCode
    }
    
    var body: some View {
        FlatTappableZStack(cornerRadius: size) {
            ZStack {
                Image(systemName: "xmark").font(Font.body.weight(.bold))
            }.frame(width: size, height: size)
                .background(settingsValues.color())
        } onTap: {
            extraCode()
            if dismissal != nil {
                dismissal!()
            } else {
                boolDismissal = false
            }
        }.frame(width: size, height: size)

    }
}
