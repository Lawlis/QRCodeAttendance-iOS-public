//
//  SelectUsersTableViewController.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-22.
//

import UIKit

class SelectUsersTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var users: [User]!
    private var filteredUsers: [User] = []
    private var selectedUsers: [User] = []
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        tableView.registerCellClass(withType: UITableViewCell.self)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterContentForSearchText(_ searchText: String) {
      filteredUsers = users.filter { (user: User) -> Bool in
        return user.name.lowercased().contains(searchText.lowercased()) || user.surname.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
           return filteredUsers.count
         }
           
         return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell()
        
        let user: User
        if isFiltering {
          user = filteredUsers[indexPath.row]
        } else {
          user = users[indexPath.row]
        }
        cell.textLabel?.text = user.name + " " + user.surname
        cell.detailTextLabel?.text = user.group?.name ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else {
            print("Failed to get cell for row at indexpath: \(indexPath)")
            return
        }
        
        if isFiltering {

        } else {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                if let index = selectedUsers.firstIndex(of: users[indexPath.row]) {
                    selectedUsers.remove(at: index)
                }
            } else {
                selectedUsers.append(users[indexPath.row])
                cell.accessoryType = .checkmark
            }
        }
    }
}

extension SelectUsersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "")
    }
}
