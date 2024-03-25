//
//  CustomAlert.swift
//  locationCounter
//
//  Created by Spencer Steadman on 1/5/23.
//

import SwiftUI

struct CustomAlert: View {
    @Binding var isAlertActive: Bool
    let alertTitle: String
    let confirmButtonText: String
    let cancelButtonText: String
    let confirmColor: Color
    
    let onConfirmTap: () -> Void
    let onCancelTap: () -> Void
    
    @State var yPosition = UIScreen.height
    @State var backgroundOpacity = 0.0
    let alertHeight = 220.0
    let alertWidth = 280.0
    let alertCornerRadius = 15.0
    
    var body: some View {
        ZStack {
            StrokeZStack(cornerRadius: alertCornerRadius) {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            
                            DismissButton(boolDismissal: $isAlertActive, size: 30) {
                                if cancelButtonText == "" {
                                    onCancelTap()
                                }
                            }
                        }.padding([.top, .trailing], UIScreen.padding)
                        Spacer().frame(height: UIScreen.padding)
                        
                        VStack {
                            Text(alertTitle)
                                .font(UILanguage.subtitleFont)
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                        }.padding([.leading, .trailing], UIScreen.padding)
                        
                        Spacer()
                        
                        HStack {
                            if cancelButtonText != "" {
                                TappableZStack(cornerRadius: alertCornerRadius) {
                                    ZStack {
                                        Text(cancelButtonText).font(UILanguage.textFont)
                                    }.frame(width: alertWidth / 2 - UIScreen.padding * 2, height: 50)
                                        .background(Color.light)
                                } onTap: {
                                    onCancelTap()
                                    isAlertActive = false
                                }.frame(width: alertWidth / 2 - UIScreen.padding * 2, height: 50)
                            }
                            TappableZStack(cornerRadius: alertCornerRadius) {
                                ZStack {
                                    Text(confirmButtonText).font(UILanguage.textFont)
                                }.frame(width: (cancelButtonText != "" ? alertWidth / 2 : alertWidth) - UIScreen.padding * (cancelButtonText != "" ? 1 : 2), height: 50)
                                    .background(confirmColor)
                            } onTap: {
                                onConfirmTap()
                                isAlertActive = false
                            }.frame(width: (cancelButtonText != "" ? alertWidth / 2 : alertWidth) - UIScreen.padding * (cancelButtonText != "" ? 1 : 2), height: 50)
                        }.padding(.bottom, UIScreen.padding)
                    }.frame(width: alertWidth, height: alertHeight)
                        .background(Color.light)
                }
            }.frame(width: alertWidth, height: alertHeight)
                .position(x: UIScreen.width / 2, y: yPosition)
            
        }.background(Color.black.opacity(backgroundOpacity))
        .onChange(of: isAlertActive) { new in
            withAnimation(.easeOut(duration: 0.3)) {
                if new {
                    yPosition = UIScreen.height / 2
                    backgroundOpacity = 0.3
                } else {
                    yPosition = UIScreen.height + alertHeight / 2
                    backgroundOpacity = 0
                }
            }
        }.onAppear {
            yPosition = UIScreen.height + alertHeight / 2
        }
    }
}
