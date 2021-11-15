
import Foundation

public final class URLSessionNetworkClient {

	private let session: URLSession

	private let queue: DispatchQueue

	public init(session: URLSession) {
		self.session = session
		self.queue = DispatchQueue(label: "URLSessionNetworkClient", qos: .userInitiated, attributes: .concurrent)
	}

	struct UnexpectedValuesRepresentation: Error { }

	@discardableResult
	public func send(request: Request, completion: @escaping (Result<(Data, HTTPURLResponse), APIError>) -> Void) -> NetworkTask {
		let networkTask = NetworkTask()
		queue.async {
			let urlRequest = request.builder.toURLRequest()

			let task = self.session.dataTask(with: urlRequest) { data, response, error in
				if let error = error {
					completion(.failure(.networkError(error)))
				} else if let apiError = APIError.error(from: response) {
					completion(.failure(apiError))
				} else if let data = data, let response = response as? HTTPURLResponse {
					completion(.success((data, response)))
				} else {
					completion(.failure(.unknownResponse))
				}
			}

			task.resume()
			networkTask.set(task)
		}

		return networkTask
	}

}
