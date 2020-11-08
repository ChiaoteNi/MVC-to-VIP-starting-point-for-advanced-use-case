//
//  MeetupEventListViewControllerTests.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2020/11/3.
//  Copyright © 2020 iOS@Taipei in iPlayground. All rights reserved.
//

import XCTest
@testable import ITApp

class MeetupEventListViewControllerTests: XCTestCase {
    
    private var sut: MeetupEventListViewController!
    
    override func setUpWithError() throws {
        sut = .init()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testShouldFetchMeetupEventsWhenViewDidLoad() throws {
        let interactorSpy: MeetupEventListBusinessLogicSpy = .init()
        sut.cp_resetInteractor(interactor: interactorSpy)
        sut.viewDidLoad()
        
        XCTAssert(interactorSpy.isFetchMeetupEventsCalled, "MeetupEventList should fetch events when viewDidLoad.")
    }

    func testShouldUpdateDataSourceAndReloadDataWhenDisplayFetchEvents() throws {
        let spy: TableViewSpy = .init()
        sut.cp_resetTableView(tableView: spy)
        
        sut.viewDidLoad()
        
        let viewModel: MeetupEventList.FetchEvents.ViewModel = .init(
            historyEvents: [Seed.Event.historyEvent, Seed.Event.dummyEvent],
            recentlyEvents: []
        )
        sut.displayMeetupEvents(viewModel: viewModel)
        XCTAssert(spy.isReloadDataCalled, "TableView should reload after displayMeetupEvents.")
        XCTAssert(spy.numberOfRows(inSection: 1) == 2, "The number of row sections 1 should be the same as historyEvents amounts.")
    }
}

extension MeetupEventListViewControllerTests {
    
    private class MeetupEventListBusinessLogicSpy: MeetupEventListBusinessLogic {
        var isFetchMeetupEventsCalled: Bool = false
        
        func fetchMeetupEvents(request: MeetupEventList.FetchEvents.Request) {
            isFetchMeetupEventsCalled = true
        }
        
        func tapFavorite(request: MeetupEventList.TapFavorite.Request) { }
        func subscribeFavoriteUpdate(request: MeetupEventList.SubscribeFavoriteUpdate.Request) { }
        func unsubscribeFavoriteUpdate(request: MeetupEventList.UnsubscribeFavoriteUpdate.Request) { }
    }
    
    private class TableViewSpy: UITableView {
        var isReloadDataCalled: Bool = false
        
        override func reloadData() {
            isReloadDataCalled = true
        }
    }
    
    private enum Seed {
        enum Event {
            
            static let historyEvent: MeetupEventList.DisplayHistoryEvent = .init(
                id: "1",
                title: "Clean Swift Workshop",
                dateText: "11月08日",
                hostName: "Aaron & Willian",
                coverImageURL: nil,
                favoriteButtonColor: .black
            )
            
            static let dummyEvent: MeetupEventList.DisplayHistoryEvent = .init(
                id: "2",
                title: "Dummy",
                dateText: "Dummy",
                hostName: "Dummy",
                coverImageURL: nil,
                favoriteButtonColor: .black
            )
        }
    }
}
