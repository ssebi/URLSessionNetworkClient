
import Foundation

public final class URLSessionNetworkClient {

    public enum Error: Swift.Error {
        case networking, invalidData
    }

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    public func get(from url: URL, completion: @escaping ((Result<HTTPURLResponse, Error>) -> Void)) {
        session.dataTask(with: url) { _, _, _ in
            
        }.resume()
    }

}
