//
//  MeetupEventListModels.swift
//  ITApp
//
//  Created by Chiaote Ni on 2020/10/28.
//  Copyright (c) 2020 iOS@Taipei in iPlayground. All rights reserved.
//
//  This file was generated by iOS@Taipei's Clean Architecture Xcode Templates, which
//  is goaled to help you apply clean architecture to your iOS projects,
//

/*
 這邊會拿來定義UseCase(這個畫面的使用情境)，像是拉資料/紀錄使用者資料/上傳圖片...等等不同操作情境
 一方面讓你規劃你這個操作的資料流要怎麼走
 二方面讓日後接手你Code的人，在剛接手時可以由這個檔案預先了解這個畫面有哪些功能
 */

import UIKit

enum MeetupEventList {
    
    typealias EventResponseItem = (meetupEvent: MeetupEvent, favoriteState: MeetupEventFavoriteState)
    
    // MARK: - Models
    
    struct DisplayRecentlyEvent { // 純脆畫面顯示用的UIModel - 最近活動
        let id: String
        let title: String
        let dateText: String // 時間要轉換成Cell實際顯示的格式，像"11月08日 (今天)"
        let hostName: String
        let coverImageURL: URL?
    }
    
    struct DisplayHistoryEvent { // 純脆畫面顯示用的UIModel - 活動紀錄
        let id: String
        let title: String
        let dateText: String // 時間要轉換成Cell實際顯示的格式，像"11月08日 (今天)"
        let hostName: String
        let coverImageURL: URL?
        let favoriteButtonColor: UIColor // 直接依照他是favorite/unfavorite，組出button所需要的顏色
    }

    // MARK: - Use cases

    enum FetchEvents {
        // VC 請 Interactor 拉資料的用
        struct Request { }

        // Interactor 從api拿到活動列表，給Presenter做轉換用
        struct Response {
            let recentlyEvents: [EventResponseItem]
            let historyEvents: [EventResponseItem]
        }

        // Presenter 將拿到API回來的資料，轉換成畫面直接可顯示的資料，給VC顯示用
        struct ViewModel {
            let historyEvents: [DisplayHistoryEvent] //
            let recentlyEvents: [DisplayRecentlyEvent]
        }
    }
    
}