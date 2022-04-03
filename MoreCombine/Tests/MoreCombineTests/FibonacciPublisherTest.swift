import XCTest
import Combine
@testable import MoreCombine

@available(iOS 13.0, *)
final class MoreCombineTests: XCTestCase {
	var cancellable: AnyCancellable?
	
	func testWithUnlimitedSubscriber() throws {
		var comleted = false
		var data = [Int]()

		// FibonacciPulisher is synchronous, so cancellable receives its value
		// when all was already published and completed, so ...
		cancellable = FibonacchiPublisher(limit: Subscribers.Demand.max(7)).sink { completion in
			XCTAssert(completion == .finished)
			comleted = true
		} receiveValue: { value in
			data.append(value)
		}
		
		XCTAssertTrue(comleted)
		XCTAssertEqual(data, [1, 2, 3, 5, 8, 13, 21])
		
		// ... so free subscriber here but not in completion block
		cancellable = nil
	}
	
	func testWithSubscriberLimitation() {
		var comleted = false
		var data = [Int]()
	
		// FibonacciPulisher is synchronous, so cancellable receives its value
		// when all was already published and completed, so ...
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
		
		// ... so free subscriber here but not in completion block
		cancellable = nil
	}
	
	func testBackPressureSink() {
		var comleted = false
		var data = [Int]()

		// FibonacciPulisher is synchronous, so cancellable receives its value
		// when all was already published and completed, so ...
		self.cancellable = FibonacchiPublisher(limit: Subscribers.Demand.max(7))
			.backPressureSink(bufferSize: 2, receiveCompletion: { completion in
				XCTAssert(completion == .finished)
				comleted = true
			}, receiveValue: {
				data.append($0)
			})
			
		XCTAssertTrue(comleted)
		XCTAssertEqual(data, [1, 2, 3, 5, 8, 13, 21])

		// ... so free subscriber here but not in completion block
		self.cancellable = nil
	}

	func testSubscriber() {
		var comleted = false
		var data = [Int]()

		let subscriber = BackPressureSubscriber<Int, Never>(bufferSize: 2) { completion in
				XCTAssert(completion == .finished)
				comleted = true
			} receiveValue: {
				data.append($0)
			}

		let fibPublisher = FibonacchiPublisher(limit: Subscribers.Demand.max(7))
		
		fibPublisher.subscribe(subscriber)
		
		XCTAssertTrue(comleted)
		XCTAssertEqual(data, [1, 2, 3, 5, 8, 13, 21])
	}
}
