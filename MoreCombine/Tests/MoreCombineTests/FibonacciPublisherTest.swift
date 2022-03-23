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
		XCTAssertEqual(data, [1, 2, 3, 5, 8, 13, 21])
	}
	
	func testWithSubscriberLimitation() {
		var comleted = false
		var data = [Int]()
	
		cancellable = FibonacchiPublisher(limit: Subscribers.Demand.max(7))
		.prefix(5)
		.sink { [weak self] completion in
			XCTAssert(completion == .finished)
			comleted = true
			self?.cancellable = nil
		} receiveValue: {
			data.append($0)
		}

		XCTAssertEqual(data, [1, 2, 3, 5, 8])
		XCTAssertTrue(comleted)
	}
	
	func testSubscriber() {
		let sub = BackPressureSubscriber()
		
		XCTAssertNotNil(sub)
	}
}
