//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Сергей Розов on 22.09.2025.
//

import Foundation

final class CategoryListViewModel {
    
    // MARK: - Bindings
    var onCategoriesChanged: (([TrackerCategory]) -> Void)?
    var onEmptyStateChanged: ((Bool) -> Void)?
    
    // MARK: - Private properties
    private let store: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?(categories)
            onEmptyStateChanged?(categories.isEmpty)
        }
    }
    private(set) var selectedCategory: String?
    
    // MARK: - Initializers
    init(store: TrackerCategoryStore = TrackerCategoryStore(),
         selectedCategory: String? = nil) {
        self.store = store
        self.selectedCategory = selectedCategory
        self.store.delegate = self
        self.categories = store.fetchCategories()
    }
    
    // MARK: - Public methods
    func fetchCategories() {
        categories = store.fetchCategories()
    }
    
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        selectedCategory = categories[index].title
    }
    
    func addCategory(title: String) {
        do {
            try store.addNewCategory(TrackerCategory(title: title, trackers: []))
        } catch {
            print("Ошибка добавления: \(error)")
        }
    }
    
    func updateCategory(oldTitle: String, newTitle: String) {
        do {
            try store.updateCategoryTitle(oldTitle: oldTitle, newTitle: newTitle)
        } catch {
            print("Ошибка обновления: \(error)")
        }
    }
    
    func deleteCategory(title: String) {
        do {
            try store.deleteCategory(withTitle: title)
        } catch {
            print("Ошибка удаления: \(error)")
        }
    }
}
    
// MARK: - TrackerCategoryStoreDelegate
extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ categories: [TrackerCategory]) {
        self.categories = categories
    }
}
