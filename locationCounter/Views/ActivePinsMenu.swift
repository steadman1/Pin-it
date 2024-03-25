//
//  ActivePinsMenu.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/27/22.
//

import Foundation
import SwiftUI
import CoreLocation.CLLocation
import MapKit

struct ActivePinsMenu: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var locationManager: LocationManager
    @ObservedObject var sharedIDArray = Location.sharedIDArray
    
    let pinBarHeight: Double
    
    var body: some View {
        let pinLocations: [Location] = Location.getLocations()
        return ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Your Pins")
                            .font(UILanguage.titleFont)
                        Spacer()
                        DismissButton(dismissal: dismiss) {}
                    }.padding(UIScreen.padding)
                    
                    YourLocationPin(region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationManager.coordinate!.latitude + 0.001,
                                                                                  longitude: locationManager.coordinate!.longitude),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.008,
                                                                          longitudeDelta: 0.008)),
                        locationManager: locationManager,
                        pinBarHeight: pinBarHeight)
                    
                    Spacer().frame(height: UIScreen.padding * 3)
                    
                    ForEach(pinLocations) { location in
                        Pin(region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.cooridnate.latitude + 0.001,
                                                                                      longitude: location.cooridnate.longitude),
                                                       span: MKCoordinateSpan(latitudeDelta: 0.008,
                                                                              longitudeDelta: 0.008)),
                            location: location,
                            locationManager: locationManager,
                            pinBarHeight: pinBarHeight)
                        
                        Spacer().frame(height: UIScreen.padding)
                    }
                }
            }
        }.background(Color.light)
            
    }
}

struct YourLocationPin: View {
    @State var region: MKCoordinateRegion
    @StateObject var locationManager: LocationManager
    
    @State var address: String?
    
    let desiredPinViewWidth = 550 - UIScreen.padding * 2
    let pinBarHeight: Double
    let pinViewCornerRadius: Double = 25
    let pinViewHeight: Double = 110
    
    var body: some View {
        let pinViewWidth = desiredPinViewWidth > UIScreen.width - UIScreen.padding * 2 ? UIScreen.width - UIScreen.padding * 2 : desiredPinViewWidth
        
        var yourLocation = Location(name: "&Me@Me.enlacasa$$",
                                indicator: "🫵",
                                address: nil,
                                latitude: locationManager.coordinate!.latitude,
                                longitude: locationManager.coordinate!.longitude,
                                stored: false)
        return StrokeZStack(cornerRadius: pinViewCornerRadius) {
            ZStack {
                HStack {
                    ZStack {
                        Map(coordinateRegion: $region,
                            interactionModes: .zoom,
                            annotationItems: [yourLocation]) { location in
                            
                            MapAnnotation(coordinate: location.cooridnate) {
                                CustomMapMarker(indicator: location.indicator,
                                                color: Color.red,
                                                count: -1,
                                                size: 55)
                            }
                        }.frame(width: pinViewHeight - UIScreen.padding * 2,
                                height: pinViewHeight - UIScreen.padding * 2)
                            .cornerRadius(pinViewCornerRadius - UIScreen.padding)
                            .disabled(true)
                    }.background(Color.white.opacity(0.0000001))
                    
                    Spacer().frame(width: UIScreen.padding)
                    
                    VStack {
                        HStack {
                            Text("Your location")
                                .font(UILanguage.subtitleFont)
                            Spacer()
                        }
                        HStack {
                            Text(address ?? "no address available")
                                .font(UILanguage.textFont)
                            Spacer()
                        }
                    }
                    
                    Spacer()
            
                }.padding(.all, UIScreen.padding)
                
//                ZStack {
//
//                }.frame(width: 30, height: 30)
//                    .background(Color.red)
//                    .cornerRadius(100)
//                    .offset(x: UIScreen.width / 2 - 15, y: -pinViewHeight / 2)
//                    .onTapGesture {
//                        location.clearLocation()
//                    }
            }.frame(width: pinViewWidth, height: pinViewHeight)
                .background(Color.light)
            
        }.frame(width: pinViewWidth, height: pinViewHeight)
            .onAppear {
                LocationManager.getAddressFromCoordinate(coordinate: locationManager.coordinate!) { _placemark in
                    guard let guardedPlacemark = _placemark else {
                        return
                    }
                    address = guardedPlacemark.fullAddress!
                }
            }
    }
}

struct Pin: View {
    @State var region: MKCoordinateRegion
    @State var isEditingPin = false
    @State var location: Location
    
    @StateObject var locationManager: LocationManager
    
    let desiredPinViewWidth = 550 - UIScreen.padding * 2
    let pinBarHeight: Double
    let pinViewCornerRadius: Double = 25
    let pinViewHeight: Double = 110
    
    var body: some View {
        let pinViewWidth = desiredPinViewWidth > UIScreen.width - UIScreen.padding * 2 ? UIScreen.width - UIScreen.padding * 2 : desiredPinViewWidth
        return TappableZStack(cornerRadius: pinViewCornerRadius) {
            ZStack {
                HStack {
                    ZStack {
                        Map(coordinateRegion: $region,
                            interactionModes: .zoom,
                            annotationItems: [location]) { location in
                            
                            MapAnnotation(coordinate: location.cooridnate) {
                                CustomMapMarker(indicator: location.indicator,
                                                color: Color.red,
                                                count: -1,
                                                size: 55)
                            }
                        }.frame(width: pinViewHeight - UIScreen.padding * 2,
                                height: pinViewHeight - UIScreen.padding * 2)
                            .cornerRadius(pinViewCornerRadius - UIScreen.padding)
                            .disabled(true)
                    }.background(Color.white.opacity(0.0000001))
                    
                    Spacer().frame(width: UIScreen.padding)
                    
                    VStack {
                        HStack {
                            Text(location.name)
                                .font(UILanguage.subtitleFont)
                            Spacer()
                        }
                        HStack {
                            Text(location.address ?? "no address available")
                                .font(UILanguage.textFont)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text(String(location.count))
                            .font(UILanguage.subtitleFont)
                        Text("visits")
                            .font(UILanguage.textFont)
                    }.frame(width: pinViewHeight - UIScreen.padding * 3,
                            height: pinViewHeight - UIScreen.padding * 2)
                        .background(Color.overlay)
                        .cornerRadius(pinViewCornerRadius - UIScreen.padding)
                    
                }.padding(.all, UIScreen.padding)
                
//                ZStack {
//                    
//                }.frame(width: 30, height: 30)
//                    .background(Color.red)
//                    .cornerRadius(100)
//                    .offset(x: UIScreen.width / 2 - 15, y: -pinViewHeight / 2)
//                    .onTapGesture {
//                        location.clearLocation()
//                    }
            }.frame(width: pinViewWidth, height: pinViewHeight)
                .background(Color.light)
            
        } onTap: {
            isEditingPin.toggle()
        }.frame(width: pinViewWidth, height: pinViewHeight)
            .sheet(isPresented: $isEditingPin) {
                EditPinMenu(location: $location,
                            locationManager: locationManager,
                            sharedIDArray: Location.sharedIDArray,
                            buttonHeight: pinBarHeight)
            }
    }
}
