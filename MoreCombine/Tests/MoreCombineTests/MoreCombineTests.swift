import XCTest
import Combine
@testable import MoreCombine

@available(iOS 13.0, *)
final class MoreCombineTests: XCTestCase {
	var cancellable: AnyCancellable?
	
	func testWithUnlimitedSubscriber() throws {
	
		var comleted = false
		var data = [Int]()
		cancellable = FibonacchiPublisher(limit: Subscribers.Demand.max(7)).sink { completion in
			XCTAssert(completion == .finished)
			comleted = true
		} receiveValue: {
			data.append($0)
		}
		
		XCTAssertTrue(comleted)
		XCTAssertEqual(data, [1, 1, 2, 3, 5, 8, 13])
		cancellable = nil
	}
}
