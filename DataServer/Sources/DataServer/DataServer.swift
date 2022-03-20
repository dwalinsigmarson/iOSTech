import Swifter
import Foundation

public struct DataServer {
	let server: HttpServer
	
    public init() {
		server = HttpServer()
    }

	public func start() {
		server["/about"] = scopes {
            html {
                body {
                    h1 {
                        inner = "People provider"
                    }
                }
            }
        }
        
        server["/test"] = {
			.ok(.htmlBody("<h1>You asked for " + $0.path + "</h1>"))
		}
        
        server["/users"] = { _ in
            Bundle.module.url(forResource: "users", withExtension: "json")
                .flatMap { try? Data(contentsOf: $0) }
                .map {
                    HttpResponse.ok(HttpResponseBody.data($0, contentType: "application/json"))
                } ?? .notFound
        }
        
        try? server.start(8080, forceIPv4: false, priority: .background)
	}
}
