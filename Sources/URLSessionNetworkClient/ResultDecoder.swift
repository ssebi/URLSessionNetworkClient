
import Foundation

public extension Result where Success == (Data, HTTPURLResponse), Failure == APIError {

	func decode<M: Decodable>(_ model: M.Type, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<M, APIError>) -> Void) {
		DispatchQueue.global().async {
			let result = self.flatMap { data, _ -> Result<M, APIError> in
				do {
					let model = try decoder.decode(M.self, from: data)
					return .success(model)
				} catch let err as DecodingError {
					return .failure(.decodingError(err))
				} catch {
					return .failure(.unhandledResponse)
				}
			}
			completion(result)
		}
	}

}
