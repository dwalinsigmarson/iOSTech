//
//  BackPressureSubscriber.swift
//  
//
//  Created by Dmitriy Davidenko on 3/23/22.
//

import Combine

@available(iOS 13.0, *)
class BackPressureSubscriber<T, E: Error>: Subscriber, Cancellable {
	typealias Input = T
	typealias Failure = E
	
	typealias CompletionBlock = (Subscribers.Completion<Failure>) ->  Void
	typealias ValueBlock = (Input) ->  Void
	
	private let completionBlock: CompletionBlock
	private let valueBlock: ValueBlock
	private let bufferSize: Int

	private var buffer = [T]()

	private var subscription: Subscription?
	
	init(bufferSize: Int, receiveCompletion: @escaping CompletionBlock, receiveValue: @escaping ValueBlock) {
		self.completionBlock = receiveCompletion
		self.valueBlock = receiveValue
		self.bufferSize = bufferSize
		buffer.reserveCapacity(bufferSize)
	}
	
	func receive(subscription: Subscription) {
		self.subscription = subscription
		
		subscription.request(.max(bufferSize))
	}
	
	func receive(_ input: T) -> Subscribers.Demand {
		if buffer.count < bufferSize {
			buffer.append(input)
			return .none
		} else {
			buffer.forEach { self.valueBlock($0) }
			buffer.removeAll()
			return .max(bufferSize)
		}
	}
	
	func receive(completion: Subscribers.Completion<E>) {
		self.completionBlock(completion)
	}
	
	func cancel() {
		self.subscription?.cancel()
	}
}

@available(iOS 13.0, *)
extension Publisher {
	func backPressureSink<T, E>(bufferSize: Int, receiveCompletion: @escaping BackPressureSubscriber<T, E>.CompletionBlock, receiveValue: @escaping BackPressureSubscriber<T, E>.ValueBlock) -> AnyCancellable where Self.Output == T, Self.Failure == E {
		
		let subscriber = BackPressureSubscriber(bufferSize: bufferSize, receiveCompletion: receiveCompletion, receiveValue: receiveValue)
		self.receive(subscriber: subscriber)
		
		return AnyCancellable(subscriber)
	}
}
