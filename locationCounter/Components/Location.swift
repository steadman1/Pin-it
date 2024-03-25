//
//  Location.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/26/22.
//

import SwiftUI
import CoreLocation

class LocationIDArray: ObservableObject {
    @Published var idArray: [UUID] = Location.loadIDs() ?? []
}

class Location: Encodable, Decodable, Identifiable {
    static var sharedIDArray = LocationIDArray()
    var id: UUID
    let name: String
    let indicator: String
    @Published var count: Int
    var address: String?
    private let latitude: Double
    private let longitude: Double
    let cooridnate: CLLocationCoordinate2D
        
    init(id: UUID = UUID(), name: String, indicator: String, address: String?, latitude: Double, longitude: Double, stored: Bool = true) {
        
        self.id = id
        self.name = name
        self.indicator = String(indicator.prefix(1))
        self.latitude = latitude
        self.longitude = longitude
        self.count = 0
        self.address = address
        self.cooridnate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if stored {
            Location.sharedIDArray.idArray.append(id)
            self.save()
            self.saveIDs(idArray: Location.sharedIDArray.idArray)
            
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        indicator = try container.decode(String.self, forKey: .indicator)
        count = try container.decode(Int.self, forKey: .count)
        address = try container.decode(String?.self, forKey: .address)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        cooridnate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if !Location.sharedIDArray.idArray.contains(id) {
            Location.sharedIDArray.idArray.append(id)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(indicator, forKey: .indicator)
        try container.encode(count, forKey: .count)
        try container.encode(address, forKey: .address)
        try container.encode(address, forKey: .address)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(false, forKey: .stored)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case indicator
        case count
        case address
        case latitude
        case longitude
        case stored
    }
}

extension Location {
    func addToCount(addToValue: Int = 1) -> Int {
        self.count += addToValue
        self.save()
        return self.count
    }
    
    func saveIDs(idArray: [UUID]) {
        let data = try? JSONEncoder().encode(idArray)
        UserDefaults.standard.set(data, forKey: "LocationIDs")
    }
    
    static func loadIDs() -> [UUID]? {
        guard let data = UserDefaults.standard.data(forKey: "LocationIDs") else {
            print("\nloadIDs returned nil\n")
            return nil
        }
        let IDs = try! JSONDecoder().decode([UUID].self, from: data)
        var returnIDs: [UUID] = []
        
        for element in IDs {
            if UserDefaults.standard.object(forKey: element.uuidString) != nil {
                returnIDs.append(element)
            }
        }
        return returnIDs
    }
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: id.uuidString)
    }
        
    static func load(id: UUID) -> Location? {
        guard let data = UserDefaults.standard.data(forKey: id.uuidString) else {
            return nil
        }
        return try! JSONDecoder().decode(Location.self, from: data)
    }
    
    func edit(_ locationEdit: Location) {
        locationEdit.id = self.id
        let data = try! JSONEncoder().encode(locationEdit)
        UserDefaults.standard.set(data, forKey: self.id.uuidString)
    }
    
    static func getLocations(array: [UUID] = Location.sharedIDArray.idArray) -> [Location] {
        
        var temporaryLocationsArray: [Location] = []
        
        if (array.count > 0) {
            for i in 0...array.count - 1 {
                
                let uncheckedStoredLocation = Location.load(id: array[i])
                guard let storedLocation = uncheckedStoredLocation else {
                    continue
                }
                temporaryLocationsArray.append(storedLocation)
            }
        }
        
        return temporaryLocationsArray
    }
    
    func clearLocation() {
        var indexOfRemovedObject: Int?
        
        UserDefaults.standard.removeObject(forKey: self.id.uuidString)
        
        for (index, element) in Location.sharedIDArray.idArray.enumerated() {
            if element == self.id {
                indexOfRemovedObject = index
                break
            }
        }
        
        if indexOfRemovedObject != nil
            && UserDefaults.standard.object(forKey: self.id.uuidString) == nil {
            
            Location.sharedIDArray.idArray.remove(at: indexOfRemovedObject!)
            
            let data = try! JSONEncoder().encode(Location.sharedIDArray.idArray)
            
            UserDefaults.standard.set(data, forKey: "LocationIDs")
        } else {
            print("failed")
        }
    }
    
    static func clearAllLocations() { // ONLY USE IN DEVELOPMENT!!!
        let loadedIDs = Location.loadIDs() ?? []

        if loadedIDs.count > 0 {
            for i in 0...loadedIDs.count - 1 {
                UserDefaults.standard.removeObject(forKey: loadedIDs[i].uuidString)
            }
        }
        UserDefaults.standard.set([], forKey: "LocationIDs")
    }
    
    static var blank = Location(name: "",
                                indicator: "",
                                address: "",
                                latitude: 0.0,
                                longitude: 0.0,
                                stored: false)
}
