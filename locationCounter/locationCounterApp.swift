//
//  locationCounterApp.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/24/22.
//

import SwiftUI

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}

@main
struct locationCounterApp: App {
    @State var isNewUser = false
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if UserDefaults.standard.object(forKey: "SettingsValues") == nil {
                        isNewUser = true
                    }
                    SettingsValues.shared.save()
                }.sheet(isPresented: $isNewUser) {
                    GeometryReader { geometry in
                        ZStack {
                            ScrollView {
                                Spacer().frame(height: UIScreen.padding * 2 + 40)
                                VStack {
                                    HStack {
                                        Text("Welcome to Pin it!")
                                            .font(UILanguage.titleFont)
                                        Spacer()
                                    }
                                        
                                    HStack {
                                        Text("Count your Pin visits in a fun and interactive way")
                                            .font(UILanguage.subtitleFont.weight(.medium))
                                        Spacer()
                                    }
                                    
                                }.frame(width: 400 > UIScreen.width - UIScreen.padding * 2 ?
                                        UIScreen.width - UIScreen.padding * 2 : 400)
                                    .padding(.leading, UIScreen.padding)
                                VStack {
                                    Image("SettingsAlwaysOn")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 300)
                                        .cornerRadius(15)
                                    StrokeZStack(cornerRadius: 15) {
                                        ZStack {
                                            Text("Enable 'Always On' location to track your Pin visits while Pin it! is in the background. Pin visits may be lost otherwise!")
                                                .font(UILanguage.textFont)
                                                .padding(.all, UIScreen.padding)
                                        }.background(Color.light)
                                    }
                                }.frame(width: 300)
                                
                                Spacer().frame(height: UIScreen.padding * 2)
                                
                                TappableZStack(cornerRadius: 25) {
                                    ZStack {
                                        Text("Continue to Pin it!")
                                            .font(UILanguage.subtitleFont)
                                    }.frame(width: 240 - UILanguage.strokeSize * 2, height: 70)
                                        .background(SettingsValues.shared.color())
                                } onTap: {
                                    isNewUser.toggle()
                                }.frame(width: 240, height: 70)
                            }.frame(width: geometry.size.width, height: geometry.size.height)
                            
                            DismissButton(boolDismissal: $isNewUser) {}
                                .position(x: geometry.size.width - 20 - UIScreen.padding, y: UIScreen.padding + 20)
                        }.frame(width: geometry.size.width, height: geometry.size.height)
                            .interactiveDismissDisabled()
                    }.background(Color.light)
                }
        }
    }
}
