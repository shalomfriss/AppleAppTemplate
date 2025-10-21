import Foundation

@globalActor
actor NetworkActor {
    static let shared: some Actor = NetworkActor()
}

final class NetworkClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    enum NetworkError: Error {
        case invalidURL
        case httpError(status: Int)
        case decodingError(Error)
        case other(Error)
    }

    func fetch<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw NetworkError.other(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NetworkError.httpError(status: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    // Example: fetch list of ItemDTO from a given endpoint
    func fetchItems(from urlString: String) async throws -> [ItemDTO] {
        try await fetch([ItemDTO].self, from: urlString)
    }
}

