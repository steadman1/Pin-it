//
//  MapView.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/25/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var sharedIDArray: LocationIDArray
    @Binding var region: MKCoordinateRegion
    
    var pinLocations: [Location]
    
    let relocateDuration = 1.2
    let resizeDuration = 0.2
    
    let cornerRadius = 30.0
    let sideBarWidth = 60.0
    
    init(locationManager: LocationManager,
         sharedIDArray: LocationIDArray,
         region: Binding<MKCoordinateRegion>) {
        
        self.locationManager = locationManager
        self.sharedIDArray = sharedIDArray
        self._region = region
        self.pinLocations = Location.getLocations(array: sharedIDArray.idArray)
        self.pinLocations.insert(Location(name: "&Me@Me.enlacasa$$",
                                          indicator: "🫵",
                                          address: nil,
                                          latitude: locationManager.coordinate!.latitude,
                                          longitude: locationManager.coordinate!.longitude,
                                          stored: false),
                              at: 0)
    }
    
    var body: some View {
        let isCentered = LocationManager.isLocationWithinRadiusOfOther(
            location1: self.region.center,
            location2: locationManager.coordinate!,
            radius: (750 * self.region.span.latitudeDelta * 50))
        
        return ZStack {
            Map(coordinateRegion: $region,
                annotationItems: pinLocations) { location in

                MapAnnotation(coordinate: location.cooridnate) {
                    CustomMapMarker(indicator: location.indicator,
                                    color: Color(red: 1, green: 0.5, blue: 0.45),
                                    count: location.name == "&Me@Me.enlacasa$$" ? -1 : location.count)
                    .rotationEffect(.degrees(LocationManager.getTilt(location: location.cooridnate, region: region)))
                }
            }
            ZStack {
                VStack {
                    Spacer()
                    ZStack {
                        Image(systemName: "plus")
                            .font(UILanguage.textFont.bold())
                            .foregroundColor(Color.dark)
                    }.frame(width: sideBarWidth, height: sideBarWidth)
                        .background(Color.white.opacity(0.000001))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: resizeDuration)) {
                                if (region.span.latitudeDelta >= 0.002) {
                                    region.span.latitudeDelta /= 3
                                    region.span.longitudeDelta /= 3
                                }
                            }
                        }
                    Spacer()
                        .frame(width: sideBarWidth / 2, height: 1.5)
                        .background(Color.gray.opacity(0.25))
                        .cornerRadius(100)
                    ZStack {
                        Image(systemName: "minus")
                            .font(UILanguage.textFont.bold())
                            .foregroundColor(Color.dark)
                    }.frame(width: sideBarWidth, height: sideBarWidth)
                        .background(Color.white.opacity(0.000001))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: resizeDuration)) {
                                if (region.span.latitudeDelta <= 50) {
                                    region.span.latitudeDelta *= 3
                                    region.span.longitudeDelta *= 3
                                }
                            }
                        }
                    Spacer()
                        .frame(width: sideBarWidth / 2, height: 1.5)
                        .background(Color.gray.opacity(0.25))
                        .cornerRadius(100)
                    ZStack {
                        Image(systemName: isCentered ? "location.fill" : "location")
                            .font(UILanguage.textFont.bold())
                            .foregroundColor(Color.dark)
                            .animation(.easeInOut(duration: 0.12), value: isCentered)
                    }.frame(width: sideBarWidth, height: sideBarWidth)
                        .background(Color.white.opacity(0.000001))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: relocateDuration)) {
                                region = MKCoordinateRegion(
                                    center: locationManager.coordinate!,
                                    span: MKCoordinateSpan(
                                        latitudeDelta: 0.02,
                                        longitudeDelta: 0.02))
                            }
                        }
                    Spacer()
                }
                    
            }.frame(width: sideBarWidth, height: sideBarWidth * 3)
                .background(
                    .ultraThinMaterial,
                    in: RoundedWeirdRectangle(_cornerRadius: cornerRadius))
                .shadow(color: Color.gray.opacity(0.35), radius: 4, x: 0, y: 2)
                .position(x: UIScreen.width - sideBarWidth / 2, y: UIScreen.height / 2)
                .onAppear {
                    region.center = locationManager.coordinate!
                }
        }
    }
}
