//
//  DummyFactory.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2020/11/5.
//  Copyright © 2020 iOS@Taipei in iPlayground. All rights reserved.
//

import Foundation
@testable import ITApp

final class DummyFactory {
    
    static func makeDummyEvent(
        id: String = "",
        title: String = "",
        description: String? = "",
        coverImageLink: String? = "",
        hostName: String = "",
        address: String? = "",
        date: Date? = Date()
    ) -> MeetupEvent {
        return MeetupEvent(
            id: id,
            title: title,
            description: description,
            coverImageLink: coverImageLink,
            hostName: hostName,
            address: address,
            date: date
        )
    }
}
