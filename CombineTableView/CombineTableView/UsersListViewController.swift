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

	func userDataURL(id: Int) -> URL? {
        var components = URLComponents()
        components.port = 8080
        components.host = "localhost"
        components.path = "/users/\(id)"
        components.scheme = "http"
        
        return components.url
	}

	lazy var userPlaceholder = User(id: 0, login: "Placeholder", avatar_url: "")
	
	var loadCellSubject = PassthroughSubject<(IndexPath, UITableViewCell), Never>()
	
	var userIDsCountCancellable: AnyCancellable?
	var cellLoadCancellable: AnyCancellable?
	
	var userIDsCount = 0
	
	var loadUserDataCancellables = [IndexPath: AnyCancellable]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

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
		
		userIDsCountCancellable = usersIDsStream?.map(\.count).sink { [weak self] count in
			self?.userIDsCount = count
			self?.tableView.reloadData()
		}

		cellLoadCancellable = usersIDsStream?
			.combineLatest(loadCellSubject)
			.compactMap { [weak self] (userIDs, cellData) -> (URL, IndexPath)? in
				guard let strongSelf = self else { return nil }

				let (indexPath, _) = cellData
				guard let url = strongSelf.userDataURL(id: userIDs[indexPath.row].id) else { return nil }
				return (url, indexPath)
			}.compactMap { [weak self] (url, indexPath) -> (AnyCancellable, IndexPath) in
				let loadUserDataCancellable = URLSession.shared.dataTaskPublisher(for: url)
				.map { (data: Data, response: URLResponse) in
					data
				}.decode(type: User.self, decoder: JSONDecoder())
				.receive(on: DispatchQueue.main)
				.eraseToAnyPublisher()
				.sink { [weak self] _ in
					self?.loadUserDataCancellables.removeValue(forKey: indexPath)
				} receiveValue: { [weak self] user in
					guard let cell = self?.tableView.cellForRow(at: indexPath) else { return }

					var content = cell.defaultContentConfiguration()
					let title = user.login
					content.text = title
					cell.contentConfiguration = content
				}

				return (loadUserDataCancellable, indexPath)
			}.sink { [weak self] (loadUserDataCancellable, indexPath) in
				self?.loadUserDataCancellables[indexPath] = loadUserDataCancellable
			}

//		cellLoadCancellable = usersIDsStream?.combineLatest(loadCellSubject)
//			.sink { (userIDs, cellData) in
//				let (indexPath, cell) = cellData
//				var content = cell.defaultContentConfiguration()
//				let title = "\(userIDs[indexPath.row])"
//				content.text = title
//				cell.contentConfiguration = content
//			}

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
        return self.userIDsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

		var content = cell.defaultContentConfiguration()
		content.text = "Loading..."
        cell.contentConfiguration = content

		loadCellSubject.send((indexPath, cell))
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
