//
//  ViewController.swift
//  StoreSearch
//
//  Created by Eduardo Vaca on 05/12/16.
//  Copyright © 2016 Vaca. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!    
    @IBOutlet weak var tableView: UITableView!
    
    let search = Search()
    var landscapeViewController: LandscapeViewController? // there will only be one if Lanscape
    

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        // Load nib
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message:
            "There was an error reading from the iTunes Store. Please try again.",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeViewController == nil else {
            return
        }
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            // IMPORTANT: This goes befor the controller access the view beacuse that
            // will trigger the view to be loaded (viewDidLoad)
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animate(alongsideTransition: { (_) in
                    controller.view.alpha = 1
                    self.searchBar.resignFirstResponder()
                    // Dismiss the popup while rotating
                    if self.presentedViewController != nil { // returns reference to a modal vc if any
                        self.dismiss(animated: true, completion: nil)
                    }
                }, completion: { (_) in
                    controller.didMove(toParentViewController: self)
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            // controller leaves the vc hierarchy by not having parent
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { (_) in
                    controller.view.alpha = 0
                }, completion: { (_) in
                    // remove controller's view from screen
                    controller.view.removeFromSuperview()
                    // truly dispose the controller
                    controller.removeFromParentViewController()
                    self.landscapeViewController = nil
            })
        }
    }
    

}

extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(for: searchBar.text!,
                                 category: category) { (success) in
                                    if !success {
                                        self.showNetworkError()
                                    }
                                    self.tableView.reloadData()                                    
                                    self.landscapeViewController?.searchResultsReceived()
            }
            
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch search.state {
        case .notSearchYet:
            fatalError("Should never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell,
                                                     for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner .startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell,
                                                 for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell,
                                                     for: indexPath) as! SearchResultCell
            cell.configure(for: list[indexPath.row])
            return cell
        }
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .loading, .noResults, .notSearchYet:
            return nil
        case .results:
            return indexPath
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
            }            
        }
    }
}



