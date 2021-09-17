
import Foundation

public final class URLSessionNetworkClient {

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    struct UnexpectedValuesRepresentation: Error { }

    public func get(from url: URL, completion: @escaping ((Result<HTTPURLResponse, Error>) -> Void)) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }

}
