
import Foundation

public class NetworkTask {

	private(set) var task: URLSessionTask?
	private(set) var cancelled = false
	private let queue = DispatchQueue(label: "com.urlsessionclient.networkTask", qos: .utility)

	public func cancel() {
		queue.sync {
			cancelled = true
			if let task = task {
				task.cancel()
			}
		}
	}

	func set(_ task: URLSessionTask) {
		queue.sync {
			self.task = task
			if cancelled {
				task.cancel()
			}
		}
	}

}
