//
//  UsersListViewController.swift
//  CombineTableView
//
//  Created by Dmytro Davydenko on 11.04.2022.
//

import UIKit
import Combine

class UsersListViewController: UITableViewController {

    lazy var usersIDURL: URL? = {
        var components = URLComponents()
        components.port = 8080
        components.host = "localhost"
        components.path = "/users"
        components.scheme = "http"
        
        return components.url
	}()

	var userIDsCountCancellable: AnyCancellable?
	var userIDsCancellable: AnyCancellable?
	
	var userIDsCount = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()

//		let stream = URLSession.shared.dataTaskPublisher(for: usersIDURL!)
//			.map { (data: Data, response: URLResponse) in
//				data
//			}.decode(type: [UserID].self, decoder: JSONDecoder()).
//

		let usersIDsStream = self.usersIDURL.map {
			URLSession.shared.dataTaskPublisher(for: $0)
			.map { (data: Data, response: URLResponse) in
				data
			}.decode(type: [UserID].self, decoder: JSONDecoder())
			.replaceError(with: [UserID]())
			.receive(on: DispatchQueue.main)
			.prepend([UserID]())
			.eraseToAnyPublisher()
			.share()
		}
		
		userIDsCountCancellable = usersIDsStream?.map(\.count).assign(to: \.userIDsCount, on: self)
		
//		userIDsCountCancellable = usersIDsStream?.map(\.count).sink(
//		receiveCompletion: { [weak self] completion in
//			self?.userIDsCountCancellable = nil
//		}, receiveValue: { [weak self] count in
//			self?.userIDsCount = count
//			self?.tableView.reloadData()
//		})
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 30
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

		var content = cell.defaultContentConfiguration()
		content.text = "\(indexPath.row)"
        // Configure the cell...
        cell.contentConfiguration = content

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


//struct User: Codable {
//    let name: String
//    let userID: String
//}
//let url = URL(string: "https://example.com/endpoint")!
//cancellable = urlSession
//    .dataTaskPublisher(for: url)
//    .tryMap() { element -> Data in
//        guard let httpResponse = element.response as? HTTPURLResponse,
//            httpResponse.statusCode == 200 else {
//                throw URLError(.badServerResponse)
//            }
//        return element.data
//        }
//    .decode(type: User.self, decoder: JSONDecoder())
//    .sink(receiveCompletion: { print ("Received completion: \($0).") },
//          receiveValue: { user in print ("Received user: \(user).")})
