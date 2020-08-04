//
//  TableViewController.swift
//  MemsGeneratorOne
//
//  Created by Jura on 20.07.2020.
//  Copyright © 2020 Jura. All rights reserved.
//

import UIKit

class ListMemos: UITableViewController {
    
    static var arrayMemos = [String]()
    var textIndexPath: String?
    var filteredMems = [String]()
    var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false}
        return text.isEmpty
    }
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search()
        getListMems()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredMems.count
        }
        return ListMemos.arrayMemos.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var memos: String
        if isFiltering {
            memos = filteredMems[indexPath.row]
        } else {
            memos = ListMemos.arrayMemos[indexPath.row]
        }
        cell.textLabel?.text = memos
        self.textIndexPath = memos
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var mems = ""
        if let indexPath = tableView.indexPathForSelectedRow {
            if isFiltering {
                mems = filteredMems[indexPath.row]
            } else {
                mems = ListMemos.arrayMemos[indexPath.row]
            }
        }
        MainVC.currentMem = mems
        
        navigationController?.popViewController(animated: true)
    }
    
    func search() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по имени"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        tableView.reloadData()
    }
    func getListMems() {
        
        let headers = [
            "x-rapidapi-host": "ronreiter-meme-generator.p.rapidapi.com",
            "x-rapidapi-key": "593d858ec7msh44787ba9e3aa6aep106925jsne707a7a50200"]
        
        guard let url = URL(string: "https://ronreiter-meme-generator.p.rapidapi.com/images") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard let data = data else {return}
            
            if (error != nil) {
                print(error ?? "")
            }
            DispatchQueue.main.async {
                do {
                    ListMemos.arrayMemos = try JSONSerialization.jsonObject(with: data, options: []) as! [String]
                    self.tableView.reloadData()
                } catch let error {
                    print(error)
                }
            }
        })
        dataTask.resume()
    }
}
extension ListMemos: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterForSearchText(searchController.searchBar.text!)
    }
    func filterForSearchText(_ searchText: String) {
        
        filteredMems = ListMemos.arrayMemos.filter({ (mems: String) -> Bool in
            return mems.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}
