//
//  SearchMainVC.swift
//  YogaLessons
//
//  Created by Eran karaso on 30/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension AllTableViewController:UISearchBarDelegate,UISearchControllerDelegate{

    @objc func initSearch() {
        isSearching = true
        present(searchController, animated: true)
//        searchController.searchBar.textField?.becomeFirstResponder()
    }
    
    
    // Create the search controller and specify that it should present its results in this same view
    func createSearchController() -> UISearchController {
        let controller = UISearchController(searchResultsController: nil)
        
        let searchBar = controller.searchBar
        
        controller.delegate = self
        searchBar.delegate = self
        
        controller.dimsBackgroundDuringPresentation = false
//        searchBar.sizeToFit()
//        controller.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = controller
        
        let types = SearchKeyType.allCases.map{ "\($0)"}.joined(separator: ", ")
        
        searchBar.placeholder = "Search by one of the options bellow"
        
        searchBar.barTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        let cancelBtnAttr:[NSAttributedString.Key:UIColor] = [.foregroundColor: .white]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelBtnAttr , for: .normal)
        
        searchBar.scopeButtonTitles = SearchKeyType.allCases.map{"\($0)"}
        searchBar.scopeBarTextColorNormal = .white
        searchBar.scopeBarTextColorSelected = .black

        return controller
    }
    
    
    func didDismissSearchController(_ searchController: UISearchController) {
        isSearching = false
        tableView.reloadSections([0], with: .automatic)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        searchType = SearchKeyType.allCases[selectedScope]
        
        if let text = searchController.searchBar.text{
            updateSearch(text)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearch(searchText)
    }
    
    func updateSearch(_ query:String) {
        
        /*let info = ["q":query,"filterKey":searchType ?? SearchKeyType.title] as [String : Any]
        
        NotificationCenter.default.post(name: ._searchQueryTyped, object: nil, userInfo: info)*/
        
        filtered[currentDataType] = dataSource.filter(dataType: currentDataType, by: searchType ?? SearchKeyType.title, query: query)
        reload()
    }

}
