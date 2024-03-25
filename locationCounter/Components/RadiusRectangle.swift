//
//  RadiusRectangle.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/26/22.
//

import Foundation
import SwiftUI

struct RoundedWeirdRectangle: Shape {
    var _cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var cornerRadius = _cornerRadius
        if rect.maxX / 2 > cornerRadius || rect.maxY / 2 > cornerRadius {
            cornerRadius = min(rect.maxX / 2, rect.maxY / 2)
        }
        
        var path = Path()
        
        path.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: -cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 0),
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY + cornerRadius))
        
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: -90),
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.maxY))
        
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        
        return path
    }
}

struct InvertedCornerRectangle: Shape {
    var cornerRadius: CGFloat
    var corner: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch corner {
            
        case .topRight:
            // Start at the top left corner
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
            
            // Add a curved segment to the top right corner
            path.addArc(
                center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
            
            
        case .bottomRight:
            // Start at the top left corner
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            
            // Add a curved segment to the top right corner
            path.addArc(
                center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY + cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 270),
                endAngle: Angle(degrees: 0),
                clockwise: false
            )
            
            // Add a line to the bottom right corner
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            
            // Add a line that returns to the top right corner
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            
            // Add a line that returns to the origin
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        default:
            return path
        }
        
        return path
    }
}
