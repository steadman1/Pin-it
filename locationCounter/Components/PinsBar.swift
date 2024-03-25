//
//  PinsBar.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/27/22.
//

import Foundation
import SwiftUI

struct PinsBar: View {
    @ObservedObject var settingsValues = SettingsValues.shared
    @State private var activePinsMenuIsPresented = false
    
    @StateObject var locationManager: LocationManager
    @Binding var addNewPinMenuIsPresented: Bool
    
    let desiredPinBarWidth: Double = 375 - UIScreen.padding * 2
    let pinBarHeight: Double
    let pinBarCornerRadius: Double = 25
    
    var body: some View {
        let pinsBarWidth = desiredPinBarWidth > UIScreen.width - UIScreen.padding * 2 ? UIScreen.width - UIScreen.padding * 2 : desiredPinBarWidth
        
        return HStack {
            TappableZStack(cornerRadius: pinBarCornerRadius) {
                ZStack {
                    Text("active pins")
                        .font(UILanguage.titleFont)
                }.frame(width: pinsBarWidth - pinBarHeight - UIScreen.padding, height: pinBarHeight)
                    .background(settingsValues.color())
            } onTap: {
                activePinsMenuIsPresented.toggle()
            }
            Spacer().frame(width: UIScreen.padding)
            TappableZStack(cornerRadius: pinBarHeight) {
                ZStack {
                    Image(systemName: "plus").font(UILanguage.subtitleFont.bold())
                }.frame(width: pinBarHeight, height: pinBarHeight)
                    .background(settingsValues.color())
            } onTap: {
                addNewPinMenuIsPresented.toggle()
            }
        }.frame(width: pinsBarWidth, height: pinBarHeight)
            .fullScreenCover(isPresented: $activePinsMenuIsPresented) {
                ActivePinsMenu(locationManager: locationManager, pinBarHeight: pinBarHeight)
            }
    }
}
