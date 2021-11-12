//
//  BasicRequestBuilder.swift
//  
//
//  Created by Sebastian Vidrea on 25.09.2021.
//

import Foundation

struct BasicRequestBuilder: RequestBuilder {

    var method: HTTPMethod

    var baseURL: URL

    var path: String?

    var params: [URLQueryItem]?

    var headers: [String : String] = [:]

}
