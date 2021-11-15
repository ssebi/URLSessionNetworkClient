//
//  RequestBuilder.swift
//  
//
//  Created by Sebastian Vidrea on 25.09.2021.
//

import Foundation

public protocol RequestBuilder {

    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String? { get }
    var params: [URLQueryItem]? { get }
    var headers: [String: String]? { get }

	func encodeRequestBody() -> Data?
    func toURLRequest() -> URLRequest

}


public extension RequestBuilder {

	func encodeRequestBody() -> Data? {
		nil
	}

    /// Default `toURLRequest()` implementation for GET requests that don't have a body
    /// - Returns: the resulting `URLRequest`
    func toURLRequest() -> URLRequest {
        let url: URL
        if let path = self.path {
            url = baseURL.appendingPathComponent(path)
        } else {
            url = baseURL
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = params

        var request = URLRequest(url: components!.url!)
		request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue.uppercased()

		request.httpBody = encodeRequestBody()

        return request
    }

}
