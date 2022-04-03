//
//  FibonacchiPublisher.swift
//
//
//  Created by Dmitriy Davidenko on 3/20/22.
//

import Combine
import Foundation

@available(iOS 13.0, macOS 10.15, *)
public struct FibonacchiPublisher: Publisher {
	
	public typealias Output = Int
	
	public typealias Failure = Never
    var limit: Subscribers.Demand
    
    public init(limit: Subscribers.Demand) {
        self.limit = limit
    }
    
	@available(iOS 13.0, *)
	public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Int == S.Input {
        let subscription = FibonacciSubscription(subscriber: subscriber, limit: self.limit)
		subscriber.receive(subscription: subscription)
	}
	
	@available(iOS 13.0, *)
    class FibonacciSubscription<S: Subscriber>: Subscription where S.Input == Int {
        var current = 1
        var previous = 0
        var limit: Subscribers.Demand
        
        var subscriber: S?
        
        init(subscriber: S, limit: Subscribers.Demand) {
            self.subscriber = subscriber
            self.limit = limit
        }
        
        func request(_ demand: Subscribers.Demand) {
			guard var requestedAmount = Swift.min(demand, self.limit).max else {
				subscriber?.receive(completion: .finished)
//				subscriber = nil
				return
			}
			
			var sent = 0
			while let subscriber = self.subscriber, sent < requestedAmount {
				let now = current + previous
				
				let moreDemand = subscriber.receive(now)
				sent += 1
				
				if let moreDemandCount = moreDemand.max {
					if let limit = self.limit.max {
						requestedAmount = Swift.min(moreDemandCount + requestedAmount, limit)
					} else {
						requestedAmount += moreDemandCount
					}
				} else if let maxLimit = self.limit.max {
					requestedAmount = maxLimit
				} else {
					// Neither local nor external limits
					subscriber.receive(completion: .finished)
	//				subscriber = nil
					return
				}
				
				previous = current
				current = now
			}

			subscriber?.receive(completion: .finished)
//			subscriber = nil
        }
        
        func cancel() {
            self.subscriber = nil
        }
        
        deinit {
			Swift.print("deinit")
		}
	}
}
