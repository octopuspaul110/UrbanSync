//
//  Font+Jakarta.swift.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 08/04/2026.
//

import Foundation
import SwiftUI


extension Font {
    static func jakarta(_ weight : JakartaWeight = .regular,size : CGFloat) -> Font {
        .custom(weight.fontName, size: size)
    }
    
    static func chillax(size: CGFloat) -> Font {
        return .custom("Chillax-Variable", size: size)
    }
    
    static let jakartaLargeTitle        = Font.custom("PlusJakartaSans-Bold", size: 34)
    static let jakartaExtraLargeTitle   = Font.custom("PlusJakartaSans-ExtraBold", size: 34)
    static let jakartaTitle             = Font.custom("PlusJakartaSans-Bold", size: 28)
    static let jakartaTitle2            = Font.custom("PlusJakartaSans-SemiBold", size: 22)
    static let jakartaTitle3            = Font.custom("PlusJakartaSans-SemiBold", size: 20)
    static let jakartaHeadline          = Font.custom("PlusJakartaSans-SemiBold", size: 17)
    static let jakartaBody              = Font.custom("PlusJakartaSans-Regular", size: 17)
    static let jakartaCallout           = Font.custom("PlusJakartaSans-Regular", size: 16)
    static let jakartaSubheadline       = Font.custom("PlusJakartaSans-Medium", size: 15)
    static let jakartaFootnote          = Font.custom("PlusJakartaSans-Regular", size: 13)
    static let jakartaCaption           = Font.custom("PlusJakartaSans-Regular", size: 12)
    static let jakartaItalic            = Font.custom("PlusJakartaSans-Italic", size: 11)
    static let jakartaItalicLight       = Font.custom("PlusJakartaSans-LightItalic", size: 11)
    static let jakartaItalicMedium      = Font.custom("PlusJakartaSans-MediumItalic", size: 15)
    static let jakartaItalicSemibold    = Font.custom("PlusJakartaSans-semiBoldItalic", size: 17)
    static let jakartaItalicbold        = Font.custom("PlusJakartaSans-BoldItalic", size: 17)
    static let jakartaCaption2          = Font.custom("PlusJakartaSans-Medium", size: 11)
}

enum JakartaWeight : String {
    case regular                        = "PlusJakartaSans-Regular"
    case medium                         = "PlusJakartaSans-Medium"
    case semibold                       = "PlusJakartaSans-Semibold"
    case bold                           = "PlusJakartaSans-Bold"
    case extraBold                      = "PlusJakartaSans-ExtraBold"
    case italic                         = "PlusJakartaSans-Italic"
    case boldItalic                     = "PlusJakartaSans-BoldItalic"
    case extraLightItalic               = "PlusJakartaSans-ExtraLightItalic"
    case Light                          = "PlusJakartaSans-Light"
    case LightItalic                    = "PlusJakartaSans-LightItalic"
    case MediumItalic                   = "PlusJakartaSans-MediumItalic"
    case semiBoldItalic                 = "PlusJakartaSans-SemiBoldItalic"
    case semiBold                       = "PlusJakartaSans-SemiBold"
    
    var fontName : String {
        rawValue
    }
}
