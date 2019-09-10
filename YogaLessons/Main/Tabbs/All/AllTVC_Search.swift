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
    }
    
    
    // Create the search controller and specify that it should present its results in this same view
    func createSearchController() -> UISearchController {
        let controller = UISearchController(searchResultsController: nil)
        
        let searchBar = controller.searchBar
        
        controller.delegate = self
        searchBar.delegate = self
        
        controller.dimsBackgroundDuringPresentation = false
        
        navigationItem.searchController = controller
        
        
        searchBar.placeholder = "searchBy".translated
        
        searchBar.barTintColor = ._accent
        searchBar.tintColor = ._btnTint
        let cancelBtnAttr:[NSAttributedString.Key:UIColor] = [.foregroundColor: .white]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelBtnAttr , for: .normal)
        
        let types:[String] = SearchKeyType.allCases.map{ $0.translated.capitalized}

        searchBar.scopeButtonTitles = types
        
        searchBar.scopeBarTextColorNormal = .white
        searchBar.scopeBarTextColorSelected = .white

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
        
        filtered[currentDataType] = dataSource.filter(dataType: currentDataType, by: searchType ?? SearchKeyType.title, query: query)
        reload()
    }

}
