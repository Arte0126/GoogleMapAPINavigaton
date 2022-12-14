//
//  EnumState.swift
//  GoogleMapAPINavigation
//
//  Created by 李晉杰 on 2022/11/29.
//

import Foundation
enum State {
    case gps
    case router
    case navigation
}
enum WidthState {
    case router
    case navigation
}
class EnumClass {
    func WidthState(value:WidthState) -> CGFloat {
        switch value {
        case .router:
            return 9
        case .navigation:
            return 15
        }
    }
}

