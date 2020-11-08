//
//  MeetupEventListInteractorTests.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2020/11/2.
//  Copyright © 2020 iOS@Taipei in iPlayground. All rights reserved.
//

import XCTest
@testable import ITApp

class MeetupEventListInteractorTests: XCTestCase {
    
    private var sut: MeetupEventListInteractor!
    private var presenterSpy: MeetupEventListPresentationLogicSpy!

    override func setUpWithError() throws {
        sut = .init()
        presenterSpy = .init()

        sut.presenter = presenterSpy
    }

    override func tearDownWithError() throws {
        sut = nil
        presenterSpy = nil
    }
    
    func testFetchEventsShouldAskWorkerToFetchAndSeperateRecentlyAndHistoryEvent() {
        let fetchEventsWorker: EventListAPIWorkerSpy = .init()
        sut.cp_resetFetchMeetupEventWorker(worker: fetchEventsWorker)
        
        let request: MeetupEventList.FetchEvents.Request = .init()
        sut.fetchMeetupEvents(request: request)
        
        XCTAssert(fetchEventsWorker.isFetchMeetupEventsCalled, "FetchEventsWorker not called.")
        
        XCTAssertEqual(
            presenterSpy.fetchEventsResponse.recentlyEvents.count,
            2,
            "Function to filter recently event goes wrong."
        )
        XCTAssertEqual(
            presenterSpy.fetchEventsResponse.historyEvents.count,
            2,
            "Function to filter history event goes wrong."
        )
        XCTAssertEqual(
            presenterSpy.fetchEventsResponse.recentlyEvents[1].meetupEvent.title,
            Seed.Event.onTodayEvent.title,
            "Function to filter recently event goes wrong."
        )
    }
    
    func testTapFavoriteShouldChangeFavoriteStateToTheOppositeState() {
        let fakeEvents: [(MeetupEvent, MeetupEventFavoriteState)] = [
            (Seed.Event.historyEvent, .favorite),
            (Seed.Event.fakeEvent, .unfavorite)
        ]
        sut.cp_resetHistoryEvents(eventResponseItems: fakeEvents)
        
        let favoriteRequest: MeetupEventList.TapFavorite.Request = .init(meetupEventID: Seed.Event.historyEvent.id)
        sut.tapFavorite(request: favoriteRequest)
        XCTAssertEqual(presenterSpy.updateEventsResponse.targetEvent.favoriteState, .unfavorite, "TapFavorite UseCase goes wrong.")
        
        let unfavoriteRequest: MeetupEventList.TapFavorite.Request = .init(meetupEventID: Seed.Event.fakeEvent.id)
        sut.tapFavorite(request: unfavoriteRequest)
        XCTAssertEqual(presenterSpy.updateEventsResponse.targetEvent.favoriteState, .favorite, "TapFavorite UseCase goes wrong.")
    }
}

extension MeetupEventListInteractorTests {
    
    private class MeetupEventListPresentationLogicSpy: MeetupEventListPresentationLogic {
        
        var isPresentMeetupEventsCalled: Bool = false
        var isPresentUpdateHistoryEventCalled: Bool = false
        
        var fetchEventsResponse: MeetupEventList.FetchEvents.Response!
        var updateEventsResponse: MeetupEventList.UpdateHistoryEvent.Response!
        
        func presentMeetupEvents(response: MeetupEventList.FetchEvents.Response) {
            isPresentMeetupEventsCalled = true
            fetchEventsResponse = response
        }
        
        func presentUpdateHistoryEvent(response: MeetupEventList.UpdateHistoryEvent.Response) {
            isPresentUpdateHistoryEventCalled = true
            updateEventsResponse = response
        }
    }
    
    private class EventListAPIWorkerSpy: MeetupEventListAPIWorker {
        
        private(set) var isFetchMeetupEventsCalled: Bool = false
        
        override func fetchMeetupEvents(callback: @escaping MeetupEventListAPIWorker.APICallback) {
            isFetchMeetupEventsCalled = true
            
            let meetupEvents: [MeetupEvent] = [
                Seed.Event.futureEvent,
                Seed.Event.onTodayEvent,
                Seed.Event.historyEvent,
                Seed.Event.fakeEvent
            ]
            callback(.success(meetupEvents))
        }
    }
    
    private enum Seed {
        enum Event {
            
            static let onTodayEvent: MeetupEvent = .init(
                id: "1",
                title: "Clean Swift",
                description: "介紹Clean Swift的實作",
                coverImageLink: "https://scontent.ftpe11-2.fna.fbcdn.net/v/t1.0-9/122747107_10220912211047274_4719583865875960298_o.jpg?_nc_cat=101&ccb=2&_nc_sid=340051&_nc_ohc=Vu7ppsWcuCMAX8WhHKQ&_nc_ht=scontent.ftpe11-2.fna&oh=d707df5107319e1af4e2741296c2e685&oe=5FC2D3A7",
                hostName: "Aaron & Willian",
                address: "張榮發基金會國際會議中心",
                date: Date()
            )
            
            static let historyEvent: MeetupEvent = .init(
                id: "2",
                title: "Clean Swift Workshop",
                description: "手把手帶你跑一遍Clean Swift的Workshop",
                coverImageLink: "https://iplayground.io/2020/logo_image.png",
                hostName: "Aaron & Willian",
                address: "張榮發基金會國際會議中心",
                date: Date.init(timeInterval: -3600 * 24 * 3, since: Date()) // 三天前的活動
            )
            
            static let futureEvent: MeetupEvent = DummyFactory.makeDummyEvent(
                date: Date(timeInterval: 3600 * 24 * 3, since: Date())
            )
            static let fakeEvent: MeetupEvent = DummyFactory.makeDummyEvent(
                id: "3",
                date: Date(timeInterval: -3600 * 24 * 4, since: Date())
            )
        }
    }
}
