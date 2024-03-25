//
//  CustomMapMarker.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/27/22.
//

import Foundation
import SwiftUI

struct CustomMapMarker: View {
    var indicator: String
    var color: Color
    var count: Int
    
    let size: Double
    
    init(indicator: String, color: Color, count: Int, size: Double = 90) {
        self.indicator = String(indicator.prefix(1))
        self.color = color
        self.count = count
        self.size = size
    }
    
    var body: some View {
        let countCount = String(count).count
        let countIndicatorWidth = (size / 3.0 + Double(countCount - 1) * 11.0)
        return VStack {
            ZStack {
                Image("Pin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .shadow(radius: 8)
                
                ZStack {
                    ZStack {
                        Text(indicator)
                            .font(.system(size: size / 2 - 5))
                    }.frame(width: size - (size >= 90 ? 37 : 10), height: size - (size >= 90 ? 37 : 10))
                        .cornerRadius(100)
                }
                
                if count >= 0 {
                    ZStack {
                        RoundedRectangle(cornerRadius: size)
                            .foregroundColor(.warning)
                            .frame(width: countIndicatorWidth, height: size / 3)
                        Text(String(count))
                            .font(UILanguage.pinCountFont)
                            .foregroundColor(Color.white)
                    }.frame(width: countIndicatorWidth + 7, height: size / 3 + 7)
                        .background(Color.stroke)
                        .cornerRadius(100)
                        .position(x: size - 18, y: 18)
                }
                
//                ZStack {
//                    ZStack {
//                        Text(indicator)
//                            .font(.system(size: size / 2))
//                    }.frame(width: size - 10, height: size - 10)
//                        .background(color)
//                        .cornerRadius(100)
//
//                }.frame(width: size, height: size)
//                    .background(Color.light)
//                    .cornerRadius(100)
//                    .padding(10)
//                    .shadow(color: Color.gray.opacity(0.75), radius: 5, y: 4)
//
//                if count >= 0 {
//                    ZStack {
//                        Text(String(count))
//                            .font(.system(size: size / 3 - 3).bold())
//                            .foregroundColor(Color.white)
//                    }.frame(minWidth: size / 2 - 8, minHeight: size / 2)
//                        .padding([.leading, .trailing], 4)
//                        .background(Color.red)
//                        .cornerRadius(100)
//                        .position(x: size + 5, y: 15)
//                }
            }
        }.padding(.bottom, size - 6)
    }
}
