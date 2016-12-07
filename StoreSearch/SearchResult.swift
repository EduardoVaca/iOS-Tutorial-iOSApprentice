//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Eduardo Vaca on 05/12/16.
//  Copyright © 2016 Vaca. All rights reserved.
//



class SearchResult {
    var name = ""
    var artistName = ""
    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""        
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
