import Foundation

struct ToDoItem: Identifiable {
    let id: Int
    let title: String
    let description: String?
    let dueDate: Date?
    var completed: Bool
}
