//
//  MeetupEventListPresenterTests.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2020/11/1.
//  Copyright © 2020 iOS@Taipei in iPlayground. All rights reserved.
//

import XCTest
@testable import ITApp

class MeetupEventListPresenterTests: XCTestCase {

    private var sut: MeetupEventListPresenter!
    private var viewControllerSpy: MeetupEventListDisplayLogicSpy!
    
    override func setUpWithError() throws {
        sut = .init()
        viewControllerSpy = .init()
        
        sut.viewController = viewControllerSpy
    }

    override func tearDownWithError() throws {
        sut = nil
        viewControllerSpy = nil
    }
    
    func testPresentUseCaseShouldAskViewControllerToDisplay() throws {
        let fetchEventsExpectation = expectation(description: "testPresentUseCase_fetchEvents")
        let updateEventsExpectation = expectation(description: "testPresentUseCase_updateHistoryEvent")
        
        viewControllerSpy.displayMeetupEventsDone = {
            fetchEventsExpectation.fulfill()
        }
        viewControllerSpy.displayUpdateHistoryEventDone = {
            updateEventsExpectation.fulfill()
        }
        
        let recentlyEvent = Seed.Event.onTodayEvent
        let historyEvent = Seed.Event.historyEvent
        let fetchEventResponse: MeetupEventList.FetchEvents.Response = .init(
            recentlyEvents: [(recentlyEvent, .favorite)],
            historyEvents: [(historyEvent, .favorite)]
        )
        
        let updateEventResponse: MeetupEventList.UpdateHistoryEvent.Response = .init(
            targetEvent: (historyEvent, .favorite)
        )
        
        sut.presentMeetupEvents(response: fetchEventResponse)
        sut.presentUpdateHistoryEvent(response: updateEventResponse)
        
        wait(for: [fetchEventsExpectation, updateEventsExpectation], timeout: 2)
        
        XCTAssert(viewControllerSpy.isDisplayMeetupEventsCalled, "DisplayMeetupEvents not called.")
        XCTAssert(viewControllerSpy.isDisplayUpdateHistoryEventCalled, "DisplayUpdateHistoryEvent not called.")
    }
    
    func testPresentFetchEventShouldFormatEventForDisplay() throws {
        let expectation = self.expectation(description: "testPresentFetchEvent")
        viewControllerSpy.displayMeetupEventsDone = {
            expectation.fulfill()
        }
        
        let recentlyEvents: [(MeetupEvent, MeetupEventFavoriteState)] = [
            (Seed.Event.onTodayEvent, .favorite)
        ]
        let historyEvents: [(MeetupEvent, MeetupEventFavoriteState)] = [
            (Seed.Event.historyEvent, .favorite),
            (Seed.Event.historyEvent, .unfavorite),
            (Seed.Event.specificDateEvent, .favorite),
            (Seed.Event.noDateEvent, .favorite),
            (Seed.Event.noCoverImageLinkEvent, .favorite),
            (Seed.Event.noAddressEvent, .favorite)
        ]
        
        let response: MeetupEventList.FetchEvents.Response = .init(
            recentlyEvents: recentlyEvents,
            historyEvents: historyEvents
        )
        sut.presentMeetupEvents(response: response)
        wait(for: [expectation], timeout: 2)
        
        let recentlyDisplayEvent = viewControllerSpy.fetchEventsViewModel.recentlyEvents.first!
        let historyDisplayEvents = viewControllerSpy.fetchEventsViewModel.historyEvents
        
        XCTAssertEqual(recentlyDisplayEvent.hostName, Seed.Event.onTodayEvent.hostName, "Host name format not correct.")
        
        XCTAssertEqual(recentlyDisplayEvent.coverImageURL, URL(string: Seed.Event.onTodayEvent.coverImageLink!), "ConverImageURL format not correct.")
        XCTAssertEqual(historyDisplayEvents[4].coverImageURL, nil, "Case with no coverImage url formet not correct.")
        
        XCTAssert(recentlyDisplayEvent.dateText.contains("(今天)"), "Date formet not correct.")
        XCTAssertEqual(historyDisplayEvents[2].dateText, "11月14日", "Date formet not correct.")
        XCTAssertEqual(historyDisplayEvents[3].dateText, "", "Case with no date formet not correct.")
        
        XCTAssertEqual(historyDisplayEvents[0].favoriteButtonColor, UIColor.itOrange, "Formet with favorite event button color not correct.")
        XCTAssertEqual(historyDisplayEvents[1].favoriteButtonColor, UIColor.itLightGray, "Formet with unfavorite event button color not correct.")
    }
    
    func testPresentUpdateHistoryEventShouldFormatEventForDisplay() throws {
        let expectation = self.expectation(description: "testPresentUpdateHistoryEvent")
        viewControllerSpy.displayUpdateHistoryEventDone = {
            expectation.fulfill()
        }
        
        let response: MeetupEventList.UpdateHistoryEvent.Response = .init(
            targetEvent: (Seed.Event.historyEvent, .favorite)
        )
        sut.presentUpdateHistoryEvent(response: response)
        wait(for: [expectation], timeout: 2)
        
        XCTAssert(!viewControllerSpy.updateEventsViewModel.targetEvent.dateText.contains("(今天)"), "Date formet not correct.")
    }
}

extension MeetupEventListPresenterTests {
    
    private class MeetupEventListDisplayLogicSpy: MeetupEventListDisplayLogic {
        
        var isDisplayMeetupEventsCalled: Bool = false
        var isDisplayUpdateHistoryEventCalled: Bool = false
        
        var fetchEventsViewModel: MeetupEventList.FetchEvents.ViewModel!
        var updateEventsViewModel: MeetupEventList.UpdateHistoryEvent.ViewModel!
        
        var displayMeetupEventsDone: (() -> Void)?
        var displayUpdateHistoryEventDone: (() -> Void)?
        
        func displayMeetupEvents(viewModel: MeetupEventList.FetchEvents.ViewModel) {
            isDisplayMeetupEventsCalled = true
            fetchEventsViewModel = viewModel
            displayMeetupEventsDone?()
        }
        
        func displayUpdateHistoryEvent(viewModel: MeetupEventList.UpdateHistoryEvent.ViewModel) {
            isDisplayUpdateHistoryEventCalled = true
            updateEventsViewModel = viewModel
            displayUpdateHistoryEventDone?()
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
            
            static let specificDateEvent: MeetupEvent = DummyFactory.makeDummyEvent(date: Date(timeIntervalSince1970: 1415923200))
            
            static let noAddressEvent: MeetupEvent = DummyFactory.makeDummyEvent(address: nil)
            static let noCoverImageLinkEvent: MeetupEvent = DummyFactory.makeDummyEvent(coverImageLink: nil)
            static let noDateEvent: MeetupEvent = DummyFactory.makeDummyEvent(date: nil)
        }
    }
}

extension UIColor {
    private static func == (l: UIColor, r: UIColor) -> Bool {
        var l_red = CGFloat(0)
        var l_green = CGFloat(0)
        var l_blue = CGFloat(0)
        var l_alpha = CGFloat(0)
        guard l.getRed(&l_red, green: &l_green, blue: &l_blue, alpha: &l_alpha) else { return false }
        
        var r_red = CGFloat(0)
        var r_green = CGFloat(0)
        var r_blue = CGFloat(0)
        var r_alpha = CGFloat(0)
        guard r.getRed(&r_red, green: &r_green, blue: &r_blue, alpha: &r_alpha) else { return false }
        
        return l_red == r_red && l_green == r_green && l_blue == r_blue && l_alpha == r_alpha
    }
}


