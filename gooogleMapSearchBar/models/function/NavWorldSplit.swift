//
//  NavWorldSplit.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/17.
//

import Foundation
class NavWorldSplit {
    func navStepsRemindProcess(navStepsRemindData:String) -> (String) {
//        var navStepsRemindDataVal:String = ""
        var navStepsRemindVal = navStepsRemindData.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            if navStepsRemindVal.count >= 12 {
                let idx = navStepsRemindVal.index(navStepsRemindVal.startIndex, offsetBy: 12)
                navStepsRemindVal.insert("\n", at: idx)
            }
       
        return navStepsRemindVal
    }
    func navStepsTittleProcess(navStepsRemindData:String) -> (String) {
        let forStepsTittle = navStepsRemindData.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: "<[^>]+>", with: ",",options: .regularExpression, range: nil)
        var itemsArray:[String] = []
        itemsArray = forStepsTittle.components(separatedBy: ",")
        var navStepsTittleVal:String = ""
        for i in 0...itemsArray.count-1 {
            if itemsArray[i].hasSuffix("街") {
                navStepsTittleVal = itemsArray[i]
            }
            if itemsArray[i].hasSuffix("路") {
                navStepsTittleVal = itemsArray[i]
            }
        }
      
        return navStepsTittleVal
    }
}
