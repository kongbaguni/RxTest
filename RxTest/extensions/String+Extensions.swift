//
//  String+Extensions.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import Foundation
extension String {
    var integerValue:Int {
        NSString(string:self).integerValue
    }
    
    var floatValue:Float {
        NSString(string:self).floatValue
    }
    
    var doubleValue:Double {
        NSString(string:self).doubleValue
    }
    
    /** 포메팅 형식으로 날짜 반환 */
    func dateValue(format:String, secondFormats:[String]? = nil)->Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        var result = formatter.date(from: self)
        for format in secondFormats ?? [] {
            formatter.dateFormat = format
            if let r = formatter.date(from: self) {
                result = r
            }
        }
        return result        
    }
    
}
