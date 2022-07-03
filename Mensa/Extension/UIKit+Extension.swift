//
//  UIKit+Extension.swift
//  DearDiary
//
//  Created by David Klopp on 08.06.22.
//

import UIKit

public let supportsMacIdiom = !(UIDevice.current.userInterfaceIdiom == .pad)

@inlinable func UIFloat(_ value: CGFloat) -> CGFloat
{
    #if targetEnvironment(macCatalyst)
    return round((value == 0.5) ? 0.5 : value * (supportsMacIdiom ? 0.77 : 1.0))
    #else
    return value
    #endif
}
