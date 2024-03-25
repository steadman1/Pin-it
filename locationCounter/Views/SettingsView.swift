//
//  InfoSheet.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/25/22.
//

import SwiftUI

struct SettingsButton: View {
    @ObservedObject var settingsValues = SettingsValues.shared
    @Binding var isSheetActive: Bool
    var body: some View {
        TappableZStack(cornerRadius: 100) {
            Image(systemName: "gearshape.fill")
                .font(UILanguage.subtitleFont.bold())
                .frame(width: 60, height: 60)
                .background(settingsValues.color())
                
        } onTap: {
            isSheetActive.toggle()
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationManager: LocationManager
    
    @State var isAlertActive = false
    
    var body: some View {
        ZStack {
            ScrollView {
                HStack {
                    Text("Settings")
                        .font(UILanguage.titleFont)
                    Spacer()
                    DismissButton(dismissal: dismiss) {}
                }.padding(.all, UIScreen.padding)
                
                VStack(spacing: 15) {
                    
                    Appearance()
                    
                    LocationSettings()
                    
                    DangerZone(isAlertActive: $isAlertActive)
                    
                }.frame(width: UIScreen.width)
            }
            CustomAlert(isAlertActive: $isAlertActive,
                        alertTitle: "Are you sure you want to clear all locations?",
                        confirmButtonText: "clear",
                        cancelButtonText: "cancel",
                        confirmColor: Color.warning) {
                Location.clearAllLocations()
            } onCancelTap: {
                
            }
        }.background(Color.light)
    }
}

struct Appearance: View {
    @StateObject var settingsValues = SettingsValues.shared
    
    let colors: [Color] = [Color("testBlue"), Color("testLeo"), Color("accentForeground"), Color("testGreen"),
                           Color("testYellow"), Color("testOrange")]
    
    var body: some View {
        let colorWidth = (UIScreen.width - UIScreen.padding * 2) / CGFloat(colors.count) - UILanguage.strokeSize * CGFloat( (colors.count - 1) / 2)
        VStack {
            HStack {
                Text("Appearance")
                    .font(UILanguage.subtitleFont)
                Spacer()
            }.padding(.leading, UIScreen.padding)
            
            Spacer().frame(height: UIScreen.padding)
            
            HStack {
                Text("App Accent")
                    .font(UILanguage.textFont)
                Spacer()
            }.padding(.leading, UIScreen.padding)
            
            HStack(spacing: 5) {
                ForEach(colors, id: \.self) { color in
                    TappableZStack(cornerRadius: 15) {
                        ZStack {
                            if settingsValues.color() == color {
                                Image(systemName: "checkmark").font(.body.bold())
                            }
                        }.frame(minWidth: colorWidth - 5, minHeight: 120)
                            .background(color)
                    } onTap: {
                        SettingsValues.shared.setColor(color)
                        SettingsValues.shared.save()
                    }.frame(height: 120)

                }
            }.padding([.leading, .trailing], UIScreen.padding)
        }
    }
}

struct LocationSettings: View {
    @StateObject var settingsValues = SettingsValues.shared
    
    let meters = [0, 20, 35, 50]
    let names = ["less", "often", "more", "extra"]
    
    var body: some View {
        VStack {
            HStack {
                Text("Location")
                    .font(UILanguage.subtitleFont)
                Spacer()
            }.padding(.leading, UIScreen.padding)
            
            Spacer().frame(height: UIScreen.padding)
            
            HStack {
                Text("Location Updates Frequency")
                    .font(UILanguage.textFont)
                Spacer()
            }.padding(.leading, UIScreen.padding)
            
            HStack(spacing: 5) {
                ForEach(names.indices) { i in
                    TappableZStack(cornerRadius: 25) {
                        Text(names[i])
                            .font(UILanguage.textFont)
                            .frame(minWidth: (UIScreen.width - UIScreen.padding * 2) / CGFloat(meters.count) - UILanguage.strokeSize * CGFloat( (meters.count - 1) / 2) - 5, minHeight: 60)
                            .background(settingsValues.distanceFilter == meters[i] ? Color.confirm : Color.light)
                    } onTap: {
                        settingsValues.distanceFilter = meters[i]
                        settingsValues.save()
                    }.frame(height: 50)
                }
            }.padding([.leading, .trailing], UIScreen.padding)
        }
    }
}

struct DangerZone: View {
    @Binding var isAlertActive: Bool
    var body: some View {
        VStack {
            HStack {
                Text("Danger Zone")
                    .font(UILanguage.subtitleFont)
                Spacer()
            }.padding(.leading, UIScreen.padding)
            
            Spacer().frame(height: UIScreen.padding)
            
            TappableZStack(cornerRadius: 25) {
                Text("Clear All Locations")
                    .font(UILanguage.subtitleFont)
                    .frame(width: 260, height: 60)
                    .background(Color.warning)
            } onTap: {
                isAlertActive.toggle()
            }.frame(width: 260, height: 60)
        }
    }
}
