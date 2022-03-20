import Combine

@available(iOS 13.0, *)
public struct FibonacchiPublisher: Publisher {
	public typealias Output = Int
	
	public typealias Failure = Never

	@available(iOS 13.0, *)
	public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Int == S.Input {
		
	}
	
	
}

public struct MoreCombine {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    
}
