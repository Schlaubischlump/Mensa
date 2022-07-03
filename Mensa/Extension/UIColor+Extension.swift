//
//  UIColor+Extension.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import UIKit

extension UIColor {
    static var defaultGreen: UIColor {
        let darkGreen = UIColor(red: 199/255, green: 255/255, blue: 45/255, alpha: 1.0)
        #if os(watchOS)
        return darkGreen
        #else
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return darkGreen
            }
            return UIColor(red: 199/255, green: 217/255, blue: 45/255, alpha: 1.0)
        }
        #endif

    }

    static var defaultBlue: UIColor {
        #if os(watchOS)
        return UIColor(red: 10/255, green: 132/255, blue: 1.0, alpha: 1.0)
        #else
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return .systemBlue
            }
            return UIColor(red: 21/255, green: 73/255, blue: 149/255, alpha: 1.0)
        }
        #endif
    }

    static var defaultBackground: UIColor {
        #if os(watchOS)
        return .black
        #else
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return .secondarySystemBackground
            }
            return .systemBackground
        }
        #endif
    }
}
