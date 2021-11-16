//
//  LoggingAdapterTests.swift
//  
//
//  Created by Sebastian Vidrea on 16.11.2021.
//

import XCTest
import URLSessionNetworkClient

class LoggingAdapterTests: XCTestCase {

	func test_init_setsTheRightTypeOfLogLevel() {
		let logLevel = LoggingAdapter.LogLevel.debug
		let sut = LoggingAdapter(logLevel: logLevel)

		XCTAssertEqual(logLevel, sut.level)
	}

}
