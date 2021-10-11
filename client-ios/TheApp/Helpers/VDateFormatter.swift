//
//  DateFormatter.swift
//  TheApp
//
//  Created by Abdulhakim Ajetunmobi on 06/08/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

import Foundation

struct VDateFormatter {
    static var formatter = DateFormatter()
    
    static func dateFor(_ timeStamp: String) -> Date? {
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter.date(from: timeStamp)
    }
}
