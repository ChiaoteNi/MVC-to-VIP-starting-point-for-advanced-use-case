//
//  MeetupEventListPresenter.swift
//  ITApp
//
//  Created by Chiaote Ni on 2020/10/28.
//  Copyright (c) 2020 iOS@Taipei in iPlayground. All rights reserved.
//
//  This file was generated by iOS@Taipei's Clean Architecture Xcode Templates, which
//  is goaled to help you apply clean architecture to your iOS projects,
//

/*
 Presenter： DataModel -> UIModel的轉換者
 負責把原本在VC / Cell身上的轉換邏輯全部放在這
 ex: Date()->"兩天前" or "11月08日", userType->"管理者" or "素人"
 */

import UIKit

protocol MeetupEventListPresentationLogic {
    func presentMeetupEvents(response: MeetupEventList.FetchEvents.Response)
    func presentUpdateHistoryEvent(response: MeetupEventList.UpdateHistoryEvent.Response)
}

final class MeetupEventListPresenter: MeetupEventListPresentationLogic {
    
    weak var viewController: MeetupEventListDisplayLogic?
    
    func presentMeetupEvents(response: MeetupEventList.FetchEvents.Response) {
        
        let historyEvents = response.historyEvents.compactMap {
            self.makeHistoryDisplayEvent(
                with: $0.meetupEvent,
                favoriteState: $0.favoriteState
            )
        }
        
        let recentlyEvents = response.recentlyEvents.compactMap {
            self.makeRecentlyDisplayEvent(
                with: $0.meetupEvent
            )
        }
        
        let viewModel: MeetupEventList.FetchEvents.ViewModel = .init(
            historyEvents: historyEvents,
            recentlyEvents: recentlyEvents
        )
        
        DispatchQueue.main.async {
            self.viewController?.displayMeetupEvents(viewModel: viewModel)
        }
    }
    
    func presentUpdateHistoryEvent(response: MeetupEventList.UpdateHistoryEvent.Response) {
        // TODO: 將response轉換成MeetupEventList.UpdateHistoryEvent.ViewModel，再轉交給VC
        
        DispatchQueue.main.async {
            self.viewController?.displayUpdateHistoryEvent(viewModel: <#T##MeetupEventList.UpdateHistoryEvent.ViewModel#>)
        }
    }
}

// MARK: - Private functions
extension MeetupEventListPresenter {
    
    private func makeRecentlyDisplayEvent(with meetupEvent: MeetupEvent) -> MeetupEventList.DisplayRecentlyEvent {
        
        var coverImageURL: URL?
        if let uri = meetupEvent.coverImageLink {
            coverImageURL = URL(string: uri)
        }
        
        return .init(
            id: meetupEvent.id,
            title: meetupEvent.title,
            dateText: makeDateText(with: meetupEvent.date),
            hostName: meetupEvent.hostName,
            coverImageURL: coverImageURL
        )
    }
    
    private func makeHistoryDisplayEvent(with meetupEvent: MeetupEvent, favoriteState: MeetupEventFavoriteState) -> MeetupEventList.DisplayHistoryEvent {
        
        var coverImageURL: URL?
        if let uri = meetupEvent.coverImageLink {
            coverImageURL = URL(string: uri)
        }
        
        let favoriteColor: UIColor
        switch favoriteState {
        case .favorite:
            favoriteColor = Constant.Color.favoriteButtonOn
        case .unfavorite:
            favoriteColor = Constant.Color.favoriteButtonOff
        }
        
        return .init(
            id: meetupEvent.id,
            title: meetupEvent.title,
            dateText: makeDateText(with: meetupEvent.date),
            hostName: meetupEvent.hostName,
            coverImageURL: coverImageURL,
            favoriteButtonColor: favoriteColor
        )
    }
    
    private func makeDateText(with eventDate: Date?) -> String {
        guard let eventDate = eventDate else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constant.dateFormat
        var dateText = formatter.string(from: eventDate)
        
        let today: Date = .init()
        if formatter.string(from: today) == dateText {
            dateText.append(Constant.Text.today)
        }
        
        return dateText
    }
}

// MARK: - Constants
extension MeetupEventListPresenter {
    
    private enum Constant {
        enum Color {
            static let favoriteButtonOn: UIColor = .itOrange
            static let favoriteButtonOff: UIColor = .itLightGray
        }
        
        enum Text {
            static var today: String { "(今天)" }
        }
        
        static var dateFormat: String { "MM月dd日" }
    }
}
