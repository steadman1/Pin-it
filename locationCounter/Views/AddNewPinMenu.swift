//
//  AddNewPinMenu.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/30/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddNewPinMenu: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @StateObject var settingsValues = SettingsValues.shared
    
    @State var addNewPinLocationCoordinatesIsPresented = false
    
    @StateObject var locationManager: LocationManager
    @ObservedObject var sharedIDArray: LocationIDArray
    
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(
            latitudeDelta: 0.005,
            longitudeDelta: 0.005))
    
    let buttonHeight: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AddNewPinLocationInformation(region: $region,
                                             locationManager: locationManager,
                                             addNewPinLocationCoordinatesIsPresented: $addNewPinLocationCoordinatesIsPresented,
                                             dismissal: dismiss,
                                             buttonHeight: buttonHeight)
                DismissButton(dismissal: dismiss) {}
                    .position(x: geometry.size.width - UIScreen.padding - 25, y: UIScreen.padding + 25)
            }.interactiveDismissDisabled()
            .onAppear {
                region.center = locationManager.coordinate!
            }.background(Color.light)
            .sheet(isPresented: $addNewPinLocationCoordinatesIsPresented) {
                ZStack {
                    AddNewPinLocationCoordinates(locationManager: locationManager,
                                                 sharedIDArray: sharedIDArray,
                                                 region: $region,
                                                 addNewPinLocationCoordinatesIsPresented: $addNewPinLocationCoordinatesIsPresented,
                                                 buttonHeight: buttonHeight)
                        
                }.interactiveDismissDisabled()
            }
        }
    }
}

struct AddNewPinLocationInformation: View {
    @StateObject var settingsValues = SettingsValues.shared
    
    @State private var name = ""
    @State var emoji = ""
    @State var placemark: CLPlacemark? = nil
    
    @State var keyboardSize = 0.0
    
    @Binding var region: MKCoordinateRegion
    @StateObject var locationManager: LocationManager
    @Binding var addNewPinLocationCoordinatesIsPresented: Bool
    
    @State var pinLocation = Location.blank
    @State var isAlertActive = false
    
    let dismissal: DismissAction
    
    let buttonHeight: Double
    let mapCornerRadius = 8.0
    let mapOffset = 5.0
    
    let fieldsHeight = 50.0
    let fieldsCornerRadius = 15.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    Spacer().frame(height: mapOffset)
                    VStack {
                        FlatTappableZStack(cornerRadius: mapCornerRadius) {
                            Map(coordinateRegion: $region,
                                interactionModes: .zoom,
                                annotationItems: [pinLocation]) { location in
                                
                                MapAnnotation(coordinate: region.center) {
                                    CustomMapMarker(indicator: location.indicator,
                                                    color: Color.red,
                                                    count: -1)
                                }
                            }.frame(width: geometry.size.width - mapOffset * 3, height: [geometry.size.width, geometry.size.height].min()! - mapOffset * 3)
                                .disabled(true)
                        } onTap: {
                            addNewPinLocationCoordinatesIsPresented.toggle()
                        }.frame(width: geometry.size.width - mapOffset * 2, height: [geometry.size.width, geometry.size.height].min()! - mapOffset * 2)
                            .background(Color.white.opacity(0.0000001))
                        
                        HStack {
                            Text("Hint: Click above to change the Pin's location☝️").font(UILanguage.hintFont.bold())
                            Spacer()
                        }.padding(.leading, mapOffset + mapCornerRadius)
                        
                        HStack {
                            ZStack {
                                TextField("Pin Name", text: $name)
                                    .textFieldStyle(DefaultTextFieldStyle())
                                    .font(UILanguage.titleFont)
                            }.frame(height: fieldsHeight)
                                .padding([.leading, .trailing], fieldsCornerRadius)
                                .background(Color.gray.opacity(0.35))
                                .cornerRadius(fieldsCornerRadius)
                            Spacer()
                            ZStack {
                                EmojiTextField(placeholder: "🏡", text: $emoji)
                                    .onReceive(emoji.publisher.prefix(emoji.count > 1 ? 2 : 1)) { newValue in
                                        self.emoji = String(newValue)
                                    }.padding(.all, fieldsHeight)
                            }.frame(width: fieldsHeight, height: fieldsHeight)
                                .background(Color.gray.opacity(0.35))
                                .cornerRadius(fieldsCornerRadius)
                        }.padding(.all, UIScreen.padding)
                        
                        HStack {
                            Text(placemark != nil ? "\(placemark!.fullAddress!)": "location unavailable")
                                .font(UILanguage.textFont)
                            ZStack {
                                Spacer()
                                    .frame(width: 3)
                                    .background(Color.gray.opacity(0.35))
                                    .cornerRadius(10)
                            }.frame(width: UIScreen.padding)
                            Image(systemName: "mappin.circle")
                            if locationManager.coordinate! != nil {
                                Text(String(round(LocationManager.distanceBetweenLocations(location1: locationManager.coordinate!, location2: region.center) * 100) / 100) + " miles away")
                                .font(UILanguage.textFont)
                            }
                        }.frame(width: geometry.size.width, height: 60)
                        HStack {
                            Text("Visit History")
                                .font(UILanguage.titleFont)
                            Spacer()
                        }.padding([.leading, .trailing], UIScreen.padding)
                        
                        VStack {
                            Text("Add this location\nfor a visit history!")
                                .font(UILanguage.textFont)
                        }
                        
                        Spacer().frame(height: UIScreen.padding * 2)
                        
                        TappableZStack(cornerRadius: buttonHeight) {
                            ZStack {
                                Text("Add New Pin")
                                    .font(UILanguage.subtitleFont)
                            }.frame(width: 240, height: buttonHeight)
                                .background(settingsValues.color())
                        } onTap: {
                            if placemark == nil {
                                isAlertActive.toggle()
                            } else {
                                Location(name: name,
                                         indicator: emoji,
                                         address: placemark?.fullAddress,
                                         latitude: region.center.latitude,
                                         longitude: region.center.longitude)
                                
                                dismissal()
                            }
                        }.frame(width: 240, height: buttonHeight)
                    }
                }.onTapGesture {
                    self.endTextEditing()
                }
                    .onChange(of: addNewPinLocationCoordinatesIsPresented) { _ in
                        LocationManager.getAddressFromCoordinate(coordinate: region.center) { _placemark in
                            
                            guard let guardedPlacemark = _placemark else {
                                return
                            }
                            placemark = guardedPlacemark
                        }
                    }
            }
        }.safeAreaInset(edge: .bottom) {
            Spacer().frame(height: UIScreen.padding * 2)
        }.onAppear {
            pinLocation = Location(name: name,
                                      indicator: emoji,
                                      address: placemark?.fullAddress,
                                      latitude: region.center.latitude,
                                      longitude: region.center.longitude,
                                      stored: false)
        }.onChange(of: emoji) { newValue in
            pinLocation = Location(name: name,
                                      indicator: newValue,
                                      address: placemark?.fullAddress,
                                      latitude: region.center.latitude,
                                      longitude: region.center.longitude,
                                      stored: false)
        }.onTapGesture {
            self.endTextEditing()
        }
        CustomAlert(isAlertActive: $isAlertActive,
                    alertTitle: "Do you want to add a location?",
                    confirmButtonText: "add location",
                    cancelButtonText: "",
                    confirmColor: Color.confirm) {
            
            addNewPinLocationCoordinatesIsPresented.toggle()
        } onCancelTap: {
            Location(name: name,
                     indicator: emoji,
                     address: placemark?.fullAddress,
                     latitude: region.center.latitude,
                     longitude: region.center.longitude)
            
            dismissal()
        }
    }
}

struct AddNewPinLocationCoordinates: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @StateObject var settingsValues = SettingsValues.shared
    
    @StateObject var locationManager: LocationManager
    @ObservedObject var sharedIDArray: LocationIDArray
    
    @Binding var region: MKCoordinateRegion
    
    @Binding var addNewPinLocationCoordinatesIsPresented: Bool
    
    let buttonHeight: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MapView(locationManager: locationManager,
                        sharedIDArray: sharedIDArray,
                        region: $region)
                TappableZStack(cornerRadius: 100) {
                    ZStack {
                        Text("set location")
                            .font(UILanguage.subtitleFont)
                    }.frame(width: buttonHeight * 2 + 50, height: buttonHeight)
                        .background(settingsValues.color())
                        
                } onTap : {
                    addNewPinLocationCoordinatesIsPresented.toggle()
                }.frame(width: buttonHeight * 2 + 50, height: buttonHeight)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - UIScreen.safeAreaInsets.bottom - buttonHeight / 2)
                CustomMapMarker(indicator: "",
                                color: Color.light,
                                count: -1)
                    .offset(y: -geometry.safeAreaInsets.bottom / 2)
                DismissButton(boolDismissal: $addNewPinLocationCoordinatesIsPresented) {}
                    .position(x: geometry.size.width - UIScreen.padding - 20, y: UIScreen.padding + 20)
            }.edgesIgnoringSafeArea(.all)
        }
    }
}
