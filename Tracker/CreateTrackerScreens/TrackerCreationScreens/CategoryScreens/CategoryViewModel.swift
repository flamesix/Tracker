import Foundation

final class CategoryViewModel {
    
    private var categories: [TrackerCategory] = []
    private let trackerCategoryStore = TrackerCategoryStore()
    var selectedCategory: String?
    
    var categoriesUpdated: (() -> Void)?

    func fetchCategories() {
        do {
            categories = try trackerCategoryStore.getCategoriesTracker()
        } catch {
            print("Can't get Categories in CategoryViewModel")
        }
        categoriesUpdated?()
    }

    func categoriesCount() -> Int {
        categories.count
    }
    
    func category(at index: Int) -> String {
        categories[index].title
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index].title
    }
}
