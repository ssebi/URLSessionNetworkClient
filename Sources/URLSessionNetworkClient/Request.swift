//
//  Request.swift
//  
//
//  Created by Sebastian Vidrea on 25.09.2021.
//

import Foundation

public struct Request {

    let builder: RequestBuilder

    public init(builder: RequestBuilder) {
        self.builder = builder
    }

    public static func basic(method: HTTPMethod = .get, baseURL: URL, path: String? = nil, params: [URLQueryItem]? = nil) -> Request {
        let builder = BasicRequestBuilder(method: method, baseURL: baseURL, path: path, params: params)
        return Request(builder: builder)
    }

}
