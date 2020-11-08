//
//  MeetupEventListViewController.swift
//  ITApp
//
//  Created by kuotinyen on 2020/10/4.
//

/*
 ViewController： 回歸畫面的顯示，以及資料流的觸發
 ex: 把UIModel無腦塞到畫面上，請interactor幫忙拉資料
 */

import UIKit
import Kingfisher

protocol MeetupEventListDisplayLogic: AnyObject {
    func displayMeetupEvents(viewModel: MeetupEventList.FetchEvents.ViewModel)
    func displayUpdateHistoryEvent(viewModel: MeetupEventList.UpdateHistoryEvent.ViewModel)
}

final class MeetupEventListViewController: UIViewController, MeetupEventListDisplayLogic {
    
    enum SectionType: Int, CaseIterable {
        case recently
        case history
    }

    private lazy var tableView: UITableView = .init()
    
    private var recentlyEvents: [MeetupEventList.DisplayRecentlyEvent] = []
    private var historyEvents: [MeetupEventList.DisplayHistoryEvent] = []
    
    private var interactor: MeetupEventListBusinessLogic?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        loadData()
        subscribeFavoriteChange()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        guard parent == nil else { return }
        unsubscribeFavoriteChange()
    }
    
    // MARK: Setup
    
    private func setup() {
        let presenter: MeetupEventListPresenter = .init()
        let interactor: MeetupEventListInteractor = .init()
        
        self.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = self
    }
    
    // MARK: - Use cases
    
    func displayMeetupEvents(viewModel: MeetupEventList.FetchEvents.ViewModel) {
        recentlyEvents = viewModel.recentlyEvents
        historyEvents = viewModel.historyEvents
        tableView.reloadData()
    }
    
    func displayUpdateHistoryEvent(viewModel: MeetupEventList.UpdateHistoryEvent.ViewModel) {
        // TODO: 用eventID抓出要更新的historyEvent，用ViewModel的內容做更新，最後請tableView reload那個dataSource所代表的Row
    }
}

// MARK: - Private functions
extension MeetupEventListViewController {
    
    private func setupViews() {
        setupTableView()
    }

    private func setupTableView() {
        tableView.register(RecentlyMeetupEventCell.self, forCellReuseIdentifier: RecentlyMeetupEventCell.reusableIdentifier)
        tableView.register(HistoryMeetupEventCell.self, forCellReuseIdentifier: HistoryMeetupEventCell.reusableIdentifier)
        tableView.register(MeetupEventListHeaderView.self, forHeaderFooterViewReuseIdentifier: MeetupEventListHeaderView.reusableIdentifier)

        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func loadData() {
        let request: MeetupEventList.FetchEvents.Request = .init()
        interactor?.fetchMeetupEvents(request: request)
    }
    
    private func subscribeFavoriteChange() {
        // TODO: 請Interactor開始監聽Favorite的狀態更新
    }
    
    private func unsubscribeFavoriteChange() {
        // TODO: 請Interactor解除監聽Favorite的狀態更新
    }
}

// MARK: - UITableView DataSource
extension MeetupEventListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let eventType = SectionType.allCases[safe: section] else { return 0 }
        
        switch eventType {
        case .recently: return recentlyEvents.count
        case .history:  return historyEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let eventType = SectionType.allCases[safe: indexPath.section] else { return UITableViewCell() }
        
        switch eventType {
        case .recently:
            if let cell = tableView.dequeueReusableCell(withIdentifier: RecentlyMeetupEventCell.reusableIdentifier, for: indexPath) as? RecentlyMeetupEventCell {
                guard let meetupEvent = recentlyEvents[safe: indexPath.row] else { return cell }
                cell.configureCell(with: meetupEvent)
                return cell
            }
        case .history:
            if let cell = tableView.dequeueReusableCell(withIdentifier: HistoryMeetupEventCell.reusableIdentifier, for: indexPath) as? HistoryMeetupEventCell {
                guard let meetupEvent = historyEvents[safe: indexPath.row] else { return cell }
                cell.configureCell(with: meetupEvent)
                cell.tapFavoriteCallBack = { [weak self] in
                    // TODO: 請interactor執行tapFavorite
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let eventType = SectionType.allCases[safe: section],
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MeetupEventListHeaderView.reusableIdentifier) as? MeetupEventListHeaderView else { return nil }
        
        switch eventType {
        case .recently:
            headerView.configureHeader(
                title: Constant.Text.recentlyEventHeader,
                font: Constant.Font.recentlyEventHeader
            )
        case .history:
            headerView.configureHeader(
                title: Constant.Text.historyEventHeader,
                font: Constant.Font.historyEventHeader
            )
        }
        
        return headerView
    }
}

// MARK: - UITableView Delegate
extension MeetupEventListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEventID: String?
        switch indexPath.section {
        case 0:     selectedEventID = recentlyEvents[safe: indexPath.row]?.id
        case 1:     selectedEventID = historyEvents[safe: indexPath.row]?.id
        default:    selectedEventID = nil
        }
        guard let eventID = selectedEventID else { return }
        
        let detailVC: MeetupEventDetailViewController = .init(meetupEventID: eventID)
        let navController: UINavigationController = .init(rootViewController: detailVC)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - Test Only methods
extension MeetupEventListViewController {
    
    // This function is a control point to reset tableView in test environment.
    func cp_resetTableView(tableView: UITableView) {
        self.tableView = tableView
    }
    
    // This function is a control point to reset interactor in test environment.
    func cp_resetInteractor(interactor: MeetupEventListBusinessLogic) {
        self.interactor = interactor
    }
}

// MARK: - Constants
extension MeetupEventListViewController {
    
    private enum Constant {
        enum Font {
            static let recentlyEventHeader: UIFont = .itLargeTitle
            static let historyEventHeader: UIFont = .itTitle
        }
        
        enum Text {
            static var recentlyEventHeader: String { "近期活動" }
            static var historyEventHeader: String { "活動紀錄" }
        }

        enum Fake {
            static var jsonFileName: String { "fake-meetup-event-list" }
            static var jsonFileExtension: String { "json" }
        }
    }
}
