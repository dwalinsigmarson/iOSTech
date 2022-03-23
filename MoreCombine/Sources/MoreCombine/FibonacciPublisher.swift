import Combine

@available(iOS 13.0, *)
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
			guard var amount = (demand > self.limit ? self.limit : demand).max else {
				subscriber?.receive(completion: .finished)
//				subscriber = nil
				return
			}
			
			while let subscriber = self.subscriber, amount > 0 {
				let now = current + previous
				let newDemand = subscriber.receive(now)
				Swift.print("\(newDemand)")
				previous = current
				current = now
				amount -= 1
			}
			
			if demand < self.limit {
				self.limit -= demand
			} else {
				subscriber?.receive(completion: .finished)
//				subscriber = nil
			}
        }
        
        func cancel() {
            self.subscriber = nil
        }
        
        deinit {
			Swift.print("deinit")
		}
        
    }
}
