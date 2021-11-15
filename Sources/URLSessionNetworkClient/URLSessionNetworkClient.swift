
import Foundation

public final class URLSessionNetworkClient {

	private let session: URLSession
	private let queue: DispatchQueue
	private var adapters: [RequestAdapter]

	public init(session: URLSession, adapters: [RequestAdapter] = []) {
		self.session = session
		self.queue = DispatchQueue(label: "URLSessionNetworkClient", qos: .userInitiated, attributes: .concurrent)
		self.adapters = adapters
	}

	struct UnexpectedValuesRepresentation: Error { }

	@discardableResult
	public func send(request: Request, completion: @escaping (Result<(Data, HTTPURLResponse), APIError>) -> Void) -> NetworkTask {
		let networkTask = NetworkTask()
		queue.async {
			var urlRequest = request.builder.toURLRequest()
			self.adapters.forEach { $0.adapt(&urlRequest) }
			self.adapters.forEach { $0.beforeSend(urlRequest) }

			let task = self.session.dataTask(with: urlRequest) { data, response, error in
				self.adapters.forEach { $0.onResponse(response: response, data: data) }

				let result: Result<(Data, HTTPURLResponse), APIError>
				if let error = error {
					result = .failure(.networkError(error))
				} else if let apiError = APIError.error(from: response) {
					result = .failure(apiError)
				} else if let data = data, let response = response as? HTTPURLResponse {
					result = .success((data, response))
				} else {
					result = .failure(.unknownResponse)
				}

				switch result {
					case .success:
						self.adapters.forEach { $0.onSuccess(request: urlRequest) }

					case .failure(let error):
						self.adapters.forEach { $0.onError(request: urlRequest, error: error) }
				}

				completion(result)
			}

			task.resume()
			networkTask.set(task)
		}

		return networkTask
	}

}
