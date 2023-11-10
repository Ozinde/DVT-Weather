//
//  DataManager.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/09.
//

import Foundation

protocol DataManager {
    func loadPList(file name: String) -> [[String: AnyObject]]
}

extension DataManager {
    func loadPList(file name: String) -> [[String: AnyObject]] {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"), let itemsData = FileManager.default.contents(atPath: path), let items = try! PropertyListSerialization.propertyList(from: itemsData, format: nil) as? [[String: AnyObject]] else {
            return [[:]]
        }
        return items
    }
}
