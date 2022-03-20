//
//  ViewController.swift
//  CombineTableView
//
//  Created by Dmytro Davydenko on 19.03.2022.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var wkWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var components = URLComponents()
        components.port = 8080
        components.host = "localhost"
        components.path = "/users"
        components.scheme = "http"
        _ = components.url.map { url in
            wkWebView.load(URLRequest(url: url))
        }
    }
}

