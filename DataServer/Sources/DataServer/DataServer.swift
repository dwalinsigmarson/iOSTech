import Swifter
import Darwin

public struct DataServer {
	let server: HttpServer
	
    public init() {
		server = HttpServer()
    }

	public func start() {
		server["/views"] = {
			.ok(.htmlBody("You asked for " + $0.path))
		}
	}
}
