//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Сергей Розов on 31.08.2025.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    // MARK: - Methods
}
