//
//  StrokeStacks.swift
//  locationCounter
//
//  Created by Spencer Steadman on 1/3/23.
//

import SwiftUI

class DesignConstants {
    static let strokeWidth = 3.0
    static let buttonYOffset = -4.0
}

struct StrokeZStack<Content: View>: View {
    let cornerRadius: Double
    let content: () -> Content

    let strokeWidth = DesignConstants.strokeWidth
    
    var body: some View {
        ZStack {
            ZStack {

            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.all, strokeWidth)
                .background(Color.stroke)
                .cornerRadius(cornerRadius)
            ZStack {
                content()
                    .cornerRadius(cornerRadius - strokeWidth)
            }.padding(.all, strokeWidth)
                .background(Color.stroke)
                .cornerRadius(cornerRadius)
        }
    }
}

struct FlatTappableZStack<Content: View>: View {
    @GestureState var isTappedGestureState = false
    let cornerRadius: Double
    let content: () -> Content
    let onTap: () -> Void

    let strokeWidth = DesignConstants.strokeWidth
    
    var body: some View {
        ZStack {
            ZStack {

            }.frame(maxWidth: .infinity - strokeWidth, maxHeight: .infinity - strokeWidth)
            .padding(.all, strokeWidth)
                .background(Color.stroke)
                .cornerRadius(cornerRadius)
            ZStack {
                content()
                    .cornerRadius(cornerRadius - strokeWidth)
            }.padding(.all, strokeWidth)
                .background(Color.stroke)
                .cornerRadius(cornerRadius)
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onTap()
                }
        }//.shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 5)
    }
}



struct TappableZStack<Content: View>: View {
    @GestureState var isTappedGestureState = false
    let cornerRadius: Double
    let content: () -> Content
    let onTap: () -> Void
    
    let delayLength = 0.035
    
    func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    let strokeWidth = DesignConstants.strokeWidth
    
    var body: some View {
        let isTappedGesture = DragGesture(minimumDistance: 0)
            .updating($isTappedGestureState) { _, state, _ in
                state = true
            }.onEnded { _ in
                delay(delayLength) {
                    onTap()
                }
            }
        
        return ZStack {
            ZStack {

            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.all, strokeWidth)
                .background(Color.stroke)
                .cornerRadius(cornerRadius)
            ZStack {
                content()
                    .cornerRadius(cornerRadius - strokeWidth)
            }.padding(.all, strokeWidth)
                .background(Color.stroke)
                .cornerRadius(cornerRadius)
                .offset(//x: isTappedGestureState ? 0 : -UILanguage.buttonYOffset,
                        y: isTappedGestureState ? 0 : DesignConstants.buttonYOffset)
                .gesture(isTappedGesture)
        }.onChange(of: isTappedGestureState) { newValue in
            delay(newValue ? 0 : delayLength ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
}
