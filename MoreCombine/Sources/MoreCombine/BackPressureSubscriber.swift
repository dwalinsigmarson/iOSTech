//
//  BackPressureSubscriber.swift
//  
//
//  Created by Dmitriy Davidenko on 3/23/22.
//

import Combine

@available(iOS 13.0, *)
class BackPressureSubscriber<T, E: Error>: Subscriber {
	typealias Input = T
	typealias Failure = E
	
	func receive(subscription: Subscription) {
		
	}
	
	func receive(_ input: T) -> Subscribers.Demand {
		
	}
	
	func receive(completion: Subscribers.Completion<E>) {
		
	}
	

}
