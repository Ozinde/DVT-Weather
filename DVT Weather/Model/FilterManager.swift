//
//  FilterManager.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/09.
//

import Foundation

class FilterManager: DataManager {
    
    func fetch() -> [ImageFilterItem] {
        var filterItems: [ImageFilterItem] = []
        for data in loadPList(file: "FilterData") {
            filterItems.append(ImageFilterItem(dict: data as! [String: String]))
        }
        
        return filterItems
    }
}
