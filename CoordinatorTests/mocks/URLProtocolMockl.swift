//
//  URLProtocolMockl.swift
//  CoordinatorTests
//
//  Created by Shalom Friss on 10/22/25.
//

import Foundation
import XCTest

actor RequestHandlerStorage {
    private var requestHandler: ( @Sendable (URLRequest) async throws -> (HTTPURLResponse, Data))?

    func setHandler(_ handler: (@Sendable (URLRequest) async throws -> (HTTPURLResponse, Data))?) async {
        requestHandler = handler
    }

    func executeHandler(for request: URLRequest) async throws -> (HTTPURLResponse, Data) {
        guard let handler = requestHandler else {
            throw MockURLProtocolError.noRequestHandler
        }
        return try await handler(request)
    }
}

// References:
// https://www.hackingwithswift.com/articles/153/how-to-test-ios-networking-code-the-easy-way
// https://nshipster.com/nsurlprotocol/
// https://medium.com/better-programming/swift-unit-test-a-datataskpublisher-with-urlprotocol-2fbda186758e
// https://forums.swift.org/t/mock-urlprotocol-with-strict-swift-6-concurrency/77135/6
// swiftlint:disable static_over_final_class
final class URLProtocolMock: URLProtocol, @unchecked Sendable {

    private static let requestHandlerStorage = RequestHandlerStorage()

    static func setHandler(_ handler: (@Sendable (URLRequest) async throws -> (HTTPURLResponse, Data))?) async {
        if handler == nil {
            await requestHandlerStorage.setHandler(nil)
            return
        }

        await requestHandlerStorage.setHandler { request in
            guard let handler else {
                throw MockURLProtocolError.noRequestHandler
            }
            return try await handler(request)
        }
    }

    func executeHandler(for request: URLRequest) async throws -> (HTTPURLResponse, Data) {
        try await Self.requestHandlerStorage.executeHandler(for: request)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Task {
            do {
                let (response, data) = try await self.executeHandler(for: request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() {}
}

enum MockURLProtocolError: Error {
    case noRequestHandler
    case invalidURL
}
