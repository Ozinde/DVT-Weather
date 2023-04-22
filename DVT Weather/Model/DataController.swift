//
//  DataController.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/24.
//

import Foundation
import CoreData

class DataController {
    
    private let persistentContainer: NSPersistentContainer
    static let shared = DataController(modelName: "DVT_Weather")
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var updateContext: NSManagedObjectContext = {
        let updateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        updateContext.parent = self.viewContext
        return updateContext
    }()
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    
}
