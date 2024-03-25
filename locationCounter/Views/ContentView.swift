//
//  ContentView.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/24/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @ObservedObject var settingsValues = SettingsValues.shared
    
    @StateObject var locationManager = LocationManager()
    @ObservedObject var sharedIDArray = Location.sharedIDArray
    @State var isSheetActive = false
    @State var addNewPinMenuIsPresented = false
    @State var locationDataAvailable = false
    
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(
            latitudeDelta: 0.005,
            longitudeDelta: 0.005))
    
    let pinBarHeight: Double = 80
    
    var body: some View {
        SettingsValues.shared = SettingsValues.load() ?? SettingsValues.shared
        return GeometryReader { geometry in
            ZStack {
                if locationDataAvailable {
                    MapView(locationManager: locationManager,
                            sharedIDArray: sharedIDArray,
                            region: $region)
                } else {
                    Text("Loading...")
                }
                SettingsButton(isSheetActive: $isSheetActive)
                    .frame(width: 40, height: 40)
                    .position(x: geometry.size.width - 30.0 - UIScreen.padding,
                              y: geometry.safeAreaInsets.top + 30.0 + UIScreen.padding)

                PinsBar(locationManager: locationManager, addNewPinMenuIsPresented: $addNewPinMenuIsPresented,
                        pinBarHeight: pinBarHeight)
                .position(x: geometry.size.width / 2, y: geometry.size.height - geometry.safeAreaInsets.bottom) // subtract the height of pinBar from 'y'
            }.edgesIgnoringSafeArea(.all)
                .onAppear {
                    UIScreen.safeAreaInsets = geometry.safeAreaInsets
                }
        }
        .onReceive(locationManager.$coordinate.dropFirst()) { _coordinate in
            guard _coordinate != nil else {
                return
            }
            locationDataAvailable = true
        }
        .onAppear() {
            locationManager.manager.requestAlwaysAuthorization()
            SettingsValues.shared = SettingsValues.load() ?? SettingsValues.shared
        }
        .fullScreenCover(isPresented: $isSheetActive) {
            SettingsView(locationManager: locationManager)
        }
        .sheet(isPresented: $addNewPinMenuIsPresented) {
            AddNewPinMenu(locationManager: locationManager,
                          sharedIDArray: sharedIDArray,
                          buttonHeight: pinBarHeight)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
