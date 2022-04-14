import Swifter
import Foundation

struct User: Codable {
	let id: Int
	let login: String
	let avatar_url: String
}

struct UserID: Codable {
	let id: Int
}

public class DataServer {
	let server: HttpServer
	
	lazy var usersData = Bundle.module.url(forResource: "users", withExtension: "json")
		.flatMap { try? Data(contentsOf: $0) }
		.flatMap {
			try? JSONDecoder().decode([User].self, from: $0)
		}
		
	lazy var usersMap =	usersData?.reduce(into: [Int: User](), { partialResult, user in
			partialResult[user.id] = user
		}) ?? [:]

	lazy var userIDs = usersData?.map { UserID(id: $0.id) } ?? []
	
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
			let userIDsData = try? JSONEncoder().encode(self.userIDs)
			
			return userIDsData.map {
				.ok(.data($0, contentType: "application/json"))
			} ?? .notFound
		}

		let userIDPath = ":path"
		server["/users/\(userIDPath)"] = { request in
			return request.params[userIDPath]
				.flatMap { Int($0) }
				.flatMap {
					self.usersMap[$0]
				}
				.flatMap {
					try? JSONEncoder().encode($0)
				}
				.map {
					.ok(.data($0, contentType: "application/json"))
				} ?? .notFound
		}
		
		try? server.start(8080, forceIPv4: false, priority: .background)
	}
}
