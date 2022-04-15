//
//  ViewController.swift
//  CombineTableView
//
//  Created by Dmytro Davydenko on 19.03.2022.
//

import UIKit
import WebKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var wkWebView: WKWebView!
    
    var loadURLCancellable: AnyCancellable?
    
    var loadURL: URL? {
        var components = URLComponents()
        components.port = 8080
        components.host = "localhost"
        components.path = "/users/103"
        components.scheme = "http"
        
        return components.url
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = self.loadURL.map { url in
            wkWebView.load(URLRequest(url: url))
        }

		scheduleUsersLoad()
    }
    
	@IBAction func refresh(_ sender: Any) {
		scheduleUsersLoad()
	}
	
	fileprivate func scheduleUsersLoad() {
		loadURLCancellable = self.loadURL.map {
			URLSession.shared.dataTaskPublisher(for: $0)
		}?.map { (data: Data, response: URLResponse) in
			data
		}.decode(type: User.self, decoder: JSONDecoder())
		.sink { [weak self] completion in
			print("\(completion)")
			self?.loadURLCancellable = nil
		} receiveValue: {
			print("\($0)")
		}
	}
}
