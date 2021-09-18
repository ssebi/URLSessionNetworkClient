
import Foundation

public final class URLSessionNetworkClient {

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    struct UnexpectedValuesRepresentation: Error { }

    public func get(from url: URL, completion: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void)) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }

}
