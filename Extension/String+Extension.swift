//
//  String+Extension.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 14/5/2024.
//

import Foundation

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    var urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    func notBlank() -> Bool{
        return self != ""
    }
    func trimOptional()-> String {
        var tmpStr = self
        tmpStr.replace("\"", with: "")
        tmpStr.replace("(", with: "")
        tmpStr.replace(")", with: "")
        tmpStr.replace("Optional", with: "")
        return tmpStr
        
    }
}
