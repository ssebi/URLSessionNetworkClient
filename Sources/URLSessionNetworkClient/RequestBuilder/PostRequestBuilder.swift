
import Foundation

struct PostRequestBuilder<Body: Encodable>: RequestBuilder {

	var method: HTTPMethod

	var baseURL: URL

	var path: String?

	var params: [URLQueryItem]?

	var headers: [String : String]?

	var encoder: JSONEncoder = JSONEncoder()

	var body: Body?

	func encodeRequestBody() -> Data? {
		guard let body = body else {
			return nil
		}

		do {
			return try encoder.encode(body)
		} catch {
			return nil
		}
	}

}
