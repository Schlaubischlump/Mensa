//
//  UIColor+Extension.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import UIKit

extension UIColor {
    static var defaultGreen: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(red: 199/255, green: 255/255, blue: 45/255, alpha: 1.0)
            }
            return UIColor(red: 199/255, green: 217/255, blue: 45/255, alpha: 1.0)

        }
    }

    static var defaultBlue: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor.systemBlue
            }
            return UIColor(red: 21/255, green: 73/255, blue: 149/255, alpha: 1.0)
        }
    }

    static var defaultBackground: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return .secondarySystemBackground
            }
            return .systemBackground
        }

    }
}
