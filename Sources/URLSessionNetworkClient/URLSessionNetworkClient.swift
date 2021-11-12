
import Foundation

public final class URLSessionNetworkClient {

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    struct UnexpectedValuesRepresentation: Error { }

    public func send(request: Request, completion: @escaping (Result<(Data, HTTPURLResponse), APIError>) -> Void) {
        let urlRequest = request.builder.toURLRequest()

        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
				completion(.failure(.networkError(error)))
			} else if let apiError = APIError.error(from: response) {
				completion(.failure(apiError))
            } else if let data = data, let response = response as? HTTPURLResponse {
				completion(.success((data, response)))
            } else {
				completion(.failure(.unknownResponse))
            }
        }.resume()
    }

}
