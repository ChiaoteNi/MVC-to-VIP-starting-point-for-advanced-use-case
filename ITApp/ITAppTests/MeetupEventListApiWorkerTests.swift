//
//  MeetupEventListAPIWorkerTests.swift
//  ITAppTests
//
//  Created by kuotinyen on 2020/10/27.
//

import XCTest
@testable import ITApp

class MeetupEventListAPIWorkerTests: XCTestCase {

    private var sut: MeetupEventListAPIWorker!

    func testFetchMeetupEventsSuccess() {
        sut = MeetupEventListAPIWorker(jsonAPIWorker: JsonAPIWorkerSuccessStub())
        sut.fetchMeetupEvents { (result: MeetupEventListAPIWorker.APIResult) in
            switch result {
            case let .success(events):
                XCTAssertEqual(events.count, 26)
            case .failure:
                XCTFail("Should not goes here.")
            }
        }
    }

    func testFetchMeetupEventsFail() {
        let jsonAPIWorker = JsonAPIWorkerFailureStub()
        jsonAPIWorker.error = NSError(domain: "1", code: 2, userInfo: nil)

        sut = MeetupEventListAPIWorker(jsonAPIWorker: jsonAPIWorker)
        sut.fetchMeetupEvents { (result: MeetupEventListAPIWorker.APIResult) in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as NSError, NSError(domain: "1", code: 2, userInfo: nil))
            case .success:
                XCTFail("Should not goes here.")
            }
        }
    }
}

// MARK: - JsonAPIWorkerMock

private extension MeetupEventListAPIWorkerTests {
    class JsonAPIWorkerSuccessStub: JsonAPIWorker {
        private let jsonFileWorker: JsonFileWorker = .init()

        override func fetchModel<Model>(from url: URL, callback: @escaping (Result<Model, Error>) -> Void) where Model : Decodable, Model : Encodable {
            jsonFileWorker.fetchModel(from: url.absoluteString, callback: callback)
        }
    }

    class JsonAPIWorkerFailureStub: JsonAPIWorker {
        private let jsonFileWorker: JsonFileWorker = .init()
        var error: Error!

        override func fetchModel<Model>(from url: URL, callback: @escaping (Result<Model, Error>) -> Void) where Model : Decodable, Model : Encodable {
            callback(.failure(error))
        }
    }
}
