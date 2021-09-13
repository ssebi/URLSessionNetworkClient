import XCTest
import URLSessionNetworkClient



final class URLSessionNetworkClientTests: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL() {
        let (sut, spy) = makeSUT()
        let task = URLSessionDataTaskSpy()
        spy.stub(url: someURL, task: task)

        sut.get(from: someURL) { _ in }

        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let (sut, spy) = makeSUT()
        let url = someURL
        let error = someError
        spy.stub(url: url, error: error)

        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
                case let .failure(receivedError as NSError):
                    XCTAssertEqual(receivedError, error)
                default:
                    XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: URLSessionNetworkClient, spy: URLSessionSpy) {
        let spy = URLSessionSpy()
        let sut = URLSessionNetworkClient(session: spy)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, spy)
    }

    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }

    private let someURL = URL(string: "https://someurl.com")!
    private let someError = NSError(domain: "Test", code: 0)


    class URLSessionSpy: HTTPSession {

        private var stubs = [URL: Stub]()

        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }

        func stub(url: URL, task: HTTPSessionTask = URLSessionDataTaskSpy(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for the given url \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

    }

    private class URLSessionDataTaskSpy: HTTPSessionTask {

        var resumeCallCount = 0

        func resume() {
            resumeCallCount += 1
        }

    }

}
