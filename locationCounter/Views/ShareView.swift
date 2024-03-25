//
//  ShareView.swift
//  locationCounter
//
//  Created by Spencer Steadman on 1/9/23.
//

import SwiftUI
import MapKit

struct ShareView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.displayScale) var displayScale
    
    var location: Location
    @StateObject var locationManager: LocationManager
    @StateObject var settingsValues = SettingsValues.shared
    
    @State private var renderedImage = Image(systemName: "photo")
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    if #available(iOS 16.0, *) {
                        renderedImage
                            .resizable()
                        //LocationImage(location: location)
                            .frame(width: geometry.size.width - UIScreen.padding * 2,
                                   height: geometry.size.width - UIScreen.padding * 2)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, y: 3)
                        
                        Spacer().frame(height: UIScreen.padding)
                        
                        ShareLink(item: renderedImage,
                                  message: Text("Download Pin it! to track your location visits!  https://apps.apple.com/us/app/pin-it-location-counter/id1663418470"),
                                  preview: SharePreview("Pin it! — \(location.name)", image: renderedImage)) {
                            
                            TappableZStack(cornerRadius: 15) {
                                ZStack {
                                    Text("Share your Pin!")
                                        .foregroundColor(.stroke)
                                        .font(UILanguage.subtitleFont)
                                }.frame(width: 220, height: 70)
                                    .background(Color(settingsValues.backgroundColor))
                            } onTap: { }.frame(width: 220, height: 70)
                                .disabled(true)
                        }

                    } else {
                        Text("Sharing requires iOS 16 or later :(").font(UILanguage.titleFont)
                    }
                }
                DismissButton(dismissal: dismiss) {}
                    .position(x: geometry.size.width - UIScreen.padding - 25, y: UIScreen.padding + 25)
            }
        }.background(Color.light)
            .onAppear {
                render()
            }
    }
    
    @MainActor func render() {
            if #available(iOS 16.0, *) {
                let renderer = ImageRenderer(content: LocationImage(location: location))
                    
                renderer.scale = displayScale

                if let uiImage = renderer.uiImage {
                    renderedImage = Image(uiImage: uiImage)
                }
            }
        }
}

struct LocationImage: View {
    let settingsValues = SettingsValues.shared
    var location: Location
    
    var body: some View {
        ZStack {
            StrokeZStack(cornerRadius: 15) {
                ZStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("I visited").font(UILanguage.shareSubtitleFont)
                            ZStack {
                                HStack(spacing: 0) {
                                    Text(location.name).font(UILanguage.shareTitleFont)
                                        .minimumScaleFactor(0.3)
                                        .lineLimit(1)
                                        .foregroundColor(.stroke)
                                    
                                    Spacer()
                                }
                            }.frame(width: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding * 4)
                            HStack {
                                Text(String(location.count))
                                    .foregroundColor(.stroke)
                                    .font(UILanguage.shareTitleFont)
                                Text("times! 😄")
                                    .foregroundColor(.stroke)
                                    .font(UILanguage.shareSubtitleFont)
                            }
                            
                            Spacer()
                        }.padding(.all, UIScreen.padding)
                        
                        Spacer()
                    }
                    
                    Image("byLiminal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70)
                        .position(x: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding * 2 - 35,
                                  y: UIScreen.padding + 20)
                    
                    ZStack {
                        Image("EarthView")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.width - UILanguage.strokeSize * 4 - UIScreen.padding * 5 - 160,
                                   height: UIScreen.width - UILanguage.strokeSize * 4 - UIScreen.padding * 5 - 160)
                            .cornerRadius(15)
                        
                        ZStack {
                            CustomMapMarker(indicator: location.indicator, color: Color.clear, count: location.count)
                                .frame(width: 0, height: 0)
                        }.scaleEffect(1)
                            .rotationEffect(.degrees(12))
                    }.position(x: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding * 2 - ((UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding) / 3) / 2,
                               y: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding * 2 - ((UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding) / 3) / 2)
                    
                    TappableZStack(cornerRadius: 15) {
                        ZStack {
                            Text("Get Pin it!")
                                .font(UILanguage.subtitleFont)
                        }.frame(width: 160, height: 70)
                            .background(Color(settingsValues.backgroundColor))
                    } onTap: { }
                        .frame(width: 160, height: 70)
                        .position(x: UILanguage.strokeSize * 2 + UIScreen.padding + 80,
                                  y: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding * 2 - 35)

                    
                }.frame(width: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding, height: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding)
                    .background(Color.light)
            }.frame(width: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding, height: UIScreen.width - UILanguage.strokeSize * 2 - UIScreen.padding)
        }.frame(width: UIScreen.width, height: UIScreen.width)
            .background(Color.light)
    }
}
