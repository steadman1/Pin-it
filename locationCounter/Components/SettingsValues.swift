//
//  Settings.swift
//  locationCounter
//
//  Created by Spencer Steadman on 1/5/23.
//

import Foundation
import SwiftUI

class SettingsValues: Encodable, Decodable, ObservableObject {
    @ObservedObject static var shared = SettingsValues(backgroundColor: "testBlue",
                                                       distanceFilter: 20)
    @Published var backgroundColor: String
    @Published var distanceFilter: Int

    init(backgroundColor: String?, distanceFilter: Int?) {
        self.backgroundColor = backgroundColor ?? "testBlue"
        self.distanceFilter = distanceFilter ?? 20
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundColor = try container.decode(String.self, forKey: .backgroundColor)
        distanceFilter = try container.decode(Int.self, forKey: .distanceFilter)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(distanceFilter, forKey: .distanceFilter)
    }
    
    private enum CodingKeys: String, CodingKey {
        case backgroundColor
        case distanceFilter
    }
    
    func color() -> Color {
        return Color(backgroundColor)
    }
    
    func setColor(_ color: Color) {
        backgroundColor = color.description.components(separatedBy: "\"")[1]
    }
}

extension SettingsValues {
    func save() {
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: "SettingsValues")
    }
        
    static func load() -> SettingsValues? {
        guard let data = UserDefaults.standard.data(forKey: "SettingsValues") else {
            return nil
        }
        
        var decode: SettingsValues
        
        do {
            decode = try JSONDecoder().decode(SettingsValues.self, from: data)
        } catch {
            decode = SettingsValues(backgroundColor: nil, distanceFilter: nil)
        }
        
        return decode
    }
}
