//
//  NetworkMockTests.swift
//  CoordinatorTests
//
//  Created by Shalom Friss on 10/22/25.
//
import Foundation
import Testing

enum TestError: Error {
    case invalidResponse
}

@Suite(.serialized)
struct NetworkMockTests {
    
    private let greetingJson = """
        {
            "greeting": "test"
        }
    """
    
    init() async {
        //        await URLProtocolMock.setHandler(nil)
    }
    
    // MARK: - Helpers
    
    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }
    
    // MARK: - Tests
    @Test
    func mockShouldReturnDesiredData() async throws {
        let url = try #require(URL(string: "https://www.apple.com/"), "Bad URL")
        guard let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
            throw TestError.invalidResponse
        }
        
        // Arrange
        await URLProtocolMock.setHandler({ _ in
            (httpResponse, Data(greetingJson.utf8))
        })
        
        let session = makeSession()
        
        // Act
        let (data, response) = try await session.data(from: url)
        
        // Assert
        let http = try #require(response as? HTTPURLResponse, "Expected HTTPURLResponse")
        #expect(http.statusCode == 200)
        
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        let dict = try #require(object as? [String: Any])
        #expect(dict["greeting"] as? String == "test")
        
        await URLProtocolMock.setHandler(nil)
    }
    
    @Test
    func mockShouldReturnInvalidResponseCorrectly() async throws {
        let url = try #require(URL(string: "https://www.apple.com/"), "Bad URL")
        guard let httpResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil) else {
            throw TestError.invalidResponse
        }
        
        // Arrange
        await URLProtocolMock.setHandler({ _ in
            (httpResponse, Data(greetingJson.utf8))
        })
        
        let session = makeSession()
        
        // Act
        let (data, response) = try await session.data(from: url)
        
        // Assert
        let http = try #require(response as? HTTPURLResponse, "Expected HTTPURLResponse")
        #expect(http.statusCode != 200)
        
        // Body is still present because URLProtocolMock provided it
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        _ = object // Add specific expectations if you have an error payload contract
        
        await URLProtocolMock.setHandler(nil)
    }
}
