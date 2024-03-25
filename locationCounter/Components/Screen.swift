//
//  Screen.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/26/22.
//

import SwiftUI
import UIKit

extension UIScreen {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let size = UIScreen.main.bounds.size
    static let padding = 15.0
    static var safeAreaInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

class UILanguage {
    static let shareTitleFont: Font = Font.custom("Nunito-Bold", size: 60)
    static let titleFont: Font = Font.custom("Nunito-Bold", size: 28)
    static let shareSubtitleFont: Font = Font.custom("Nunito-Bold", size: 28)
    static let subtitleFont: Font = Font.custom("Nunito-Bold", size: 22)
    static let pinCountFont: Font = Font.custom("Nunito-Bold", size: 20)
    static let textFont: Font = Font.custom("Nunito-Medium", size: 17)
    static let hintFont: Font = Font.custom("Nunito-Medium", size: 13)
    static let strokeSize = 3.0
    static let buttonYOffset = -4.0
}
