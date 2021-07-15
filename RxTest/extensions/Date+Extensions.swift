//
//  Date+Extensions.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import Foundation
extension Date {
    /** 포메팅 한 문자열 반환*/
    func formatedString(format:String)->String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}
