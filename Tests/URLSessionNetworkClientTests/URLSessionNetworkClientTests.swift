import XCTest
import URLSessionNetworkClient

final class URLSessionNetworkClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let (sut, spy) = makeSUT()

        sut.get(from: someURL) { _ in }

        XCTAssertEqual(spy.receivedURLS, [someURL])
    }

    func test_getFromURL_resumesDataTaskWithURL() {
        let (sut, spy) = makeSUT()
        let task = URLSessionDataTaskSpy()
        spy.stub(url: someURL, task: task)
        sut.get(from: someURL) { _ in }

        XCTAssertEqual(task.resumeCallCount, 1)
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


    class URLSessionSpy: URLSession {

        var receivedURLS = [URL]()
        private var stubs = [URL: URLSessionDataTask]()

        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLS.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }

    }

    private class FakeURLSessionDataTask: URLSessionDataTask {

        override func resume() { }

    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {

        var resumeCallCount = 0

        override func resume() {
            resumeCallCount += 1
        }

    }

}
