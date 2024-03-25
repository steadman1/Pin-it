//
//  EditPinView.swift
//  locationCounter
//
//  Created by Spencer Steadman on 1/4/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct EditPinMenu: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @StateObject var settingsValues = SettingsValues.shared
    
    @State var addNewPinLocationCoordinatesIsPresented = false
    @State var sharePinIsPresented = false
    
    @State var isAlertActive = false
    
    @Binding var location: Location
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
                EditPinLocationInformation(location: $location,
                                           locationManager: locationManager,
                                           region: $region,
                                           addNewPinLocationCoordinatesIsPresented: $addNewPinLocationCoordinatesIsPresented,
                                           dismissal: dismiss,
                                           buttonHeight: buttonHeight)
                DeleteButton() {
                    isAlertActive.toggle()
                }.position(x: UIScreen.padding + 25, y: UIScreen.padding + 25)
                DismissButton(dismissal: dismiss) {}
                    .position(x: geometry.size.width - UIScreen.padding - 25, y: UIScreen.padding + 25)
                ShareButton() {
                    sharePinIsPresented.toggle()
                }.position(x: geometry.size.width - UIScreen.padding - 80, y: UIScreen.padding + 25)
                
                CustomAlert(isAlertActive: $isAlertActive,
                            alertTitle: "Are you sure you want to delete this location?",
                            confirmButtonText: "delete",
                            cancelButtonText: "cancel",
                            confirmColor: Color.warning) {
                    
                    dismiss()
                    location.clearLocation()
                } onCancelTap: {
                    
                }

                
            }.onAppear {
                region.center = location.cooridnate
            }.background(Color.light)
            .sheet(isPresented: $addNewPinLocationCoordinatesIsPresented) {
                ZStack {
                    EditPinLocationCoordinates(location: $location,
                                               sharedIDArray: sharedIDArray,
                                               locationManager: locationManager,
                                               region: $region,
                                               addNewPinLocationCoordinatesIsPresented: $addNewPinLocationCoordinatesIsPresented,
                                               buttonHeight: buttonHeight)
                        
                }
            }
        }.sheet(isPresented: $sharePinIsPresented) {
            ShareView(location: location, locationManager: locationManager)
        }
    }
}

struct EditPinLocationInformation: View {
    @StateObject var settingsValues = SettingsValues.shared
    
    @State private var name = ""
    @State var emoji = ""
    @State var address: String? = nil
    
    @State var keyboardSize = 0.0
    
    @Binding var location: Location
    @StateObject var locationManager: LocationManager
    @Binding var region: MKCoordinateRegion
    @Binding var addNewPinLocationCoordinatesIsPresented: Bool
    
    @State var pinLocation = Location.blank
    
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
                            Text(location.address ?? "location unavailable")
                                .font(UILanguage.textFont)
                            ZStack {
                                Spacer()
                                    .frame(width: 3)
                                    .background(Color.gray.opacity(0.35))
                                    .cornerRadius(10)
                            }.frame(width: UIScreen.padding)
                            Image(systemName: "mappin.circle")
                            if locationManager.coordinate != nil {
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
                            Text("Coming soon!")
                                .font(UILanguage.textFont)
                        }
                        
                        Spacer().frame(height: UIScreen.padding * 2)
                        
                        TappableZStack(cornerRadius: buttonHeight) {
                            ZStack {
                                Text("Edit Pin")
                                    .font(UILanguage.subtitleFont)
                            }.frame(width: 180, height: buttonHeight)
                                .background(settingsValues.color())
                        } onTap: {
                            let locationEdit = Location(id: location.id,
                                                        name: name,
                                                        indicator: emoji,
                                                        address: location.address,
                                                        latitude: region.center.latitude,
                                                        longitude: region.center.longitude,
                                                        stored: false)
                            
                            location.edit(locationEdit)
                            location = locationEdit
                            
                            dismissal()
                        }.frame(width: 180, height: buttonHeight)
                    }
                }.onChange(of: addNewPinLocationCoordinatesIsPresented) { _ in
                        print("VALUE UPDATED")
                        LocationManager.getAddressFromCoordinate(coordinate: region.center) { _placemark in
                            
                            guard let guardedPlacemark = _placemark else {
                                return
                            }
                            location.address = guardedPlacemark.fullAddress
                        }
                    }
            }
        }.safeAreaInset(edge: .bottom) {
            Spacer().frame(height: UIScreen.padding * 2)
        }.onAppear {
            name = location.name
            emoji = location.indicator
            address = location.address
            pinLocation = Location(name: name,
                                   indicator: emoji,
                                   address: location.address,
                                   latitude: region.center.latitude,
                                   longitude: region.center.longitude,
                                   stored: false)
        }.onChange(of: emoji) { newValue in
            pinLocation = Location(name: name,
                                      indicator: newValue,
                                   address: location.address,
                                      latitude: region.center.latitude,
                                      longitude: region.center.longitude,
                                      stored: false)
        }.onTapGesture {
            self.endTextEditing()
        }
    }
}

struct EditPinLocationCoordinates: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @StateObject var settingsValues = SettingsValues.shared
    
    @Binding var location: Location
    @ObservedObject var sharedIDArray: LocationIDArray
    @StateObject var locationManager: LocationManager
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
                        .background(SettingsValues.shared.color())
                        
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
                .interactiveDismissDisabled()
        }
    }
}
