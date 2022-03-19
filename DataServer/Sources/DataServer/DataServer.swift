import Swifter
import Darwin

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
  
        try? server.start(8080, forceIPv4: false, priority: .background)
	}
}
