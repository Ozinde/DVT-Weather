//
//  FilterItem.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/09.
//

import Foundation

struct ImageFilterItem {
    
    let filter: String?
    let name: String?
    
    init(dict: [String: String]) {
        self.filter = dict["filter"]
        self.name = dict["name"]
    }
}
