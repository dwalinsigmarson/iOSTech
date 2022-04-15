//
//  User.swift
//  CombineTableView
//
//  Created by Dmitriy Davidenko on 4/15/22.
//

import Foundation

struct User: Codable {
	let id: Int
	let login: String
	let avatar_url: String
}

struct UserID: Codable {
	let id: Int
}
