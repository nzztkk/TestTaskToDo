import SwiftUI
import Combine

class ToDoListViewController: ObservableObject {
    @Published var tasks: [ToDoItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    @Published var showCreateView: Bool = false
    
    @Published var newTaskTitle: String = ""
    @Published var newTaskDescription: String = ""
    @Published var newTaskDueDate: Date? = nil
    @Published var isDueDateEnabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // Заглушка для API и CoreData
    private let apiService = APIService()
    private let coreDataManager = CoreDataManager()
    
    init() {
        fetchTasks()
    }
    
    func fetchTasks() {
        isLoading = true
        showError = false
        errorMessage = nil
        
        apiService.fetchTasks()
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Не удалось загрузить задачи: \(error.localizedDescription)"
                    self.showError = true
                    // Загружаем тестовые данные при ошибке
                    self.tasks = self.loadFallbackTasks()
                case .finished:
                    break
                }
            }, receiveValue: { tasks in
                self.tasks = tasks
                self.saveToCoreData(tasks)
            })
            .store(in: &cancellables)
    }
    
    func toggleTaskCompletion(_ task: ToDoItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.completed.toggle()
            tasks[index] = updatedTask
            saveToCoreData(tasks)
        }
    }
    
    func presentCreateView() {
        newTaskTitle = ""
        newTaskDescription = ""
        newTaskDueDate = nil
        isDueDateEnabled = false
        showCreateView = true
    }
    
    func cancelCreate() {
        showCreateView = false
    }
    
    func saveTask() {
        let title = newTaskTitle.isEmpty ? "Новая задача" : newTaskTitle
        let newTask = ToDoItem(
            id: tasks.count + 1,
            title: title,
            description: newTaskDescription.isEmpty ? nil : newTaskDescription,
            dueDate: isDueDateEnabled ? newTaskDueDate : nil,
            completed: false
        )
        tasks.append(newTask)
        saveToCoreData(tasks)
        showCreateView = false
    }
    
    private func saveToCoreData(_ tasks: [ToDoItem]) {
        coreDataManager.saveTasks(tasks)
    }
    
    // Тестовые данные на случай оффлайн-режима
    private func loadFallbackTasks() -> [ToDoItem] {
        return [
            ToDoItem(id: 1, title: "Тестовая задача 1", description: nil, dueDate: nil, completed: false),
            ToDoItem(id: 2, title: "Тестовая задача 2", description: nil, dueDate: nil, completed: true),
            ToDoItem(id: 1, title: "Тестовая задача 1", description: nil, dueDate: nil, completed: false),
            ToDoItem(id: 2, title: "Тестовая задача 2", description: nil, dueDate: nil, completed: true),
            ToDoItem(id: 1, title: "Тестовая задача 1", description: nil, dueDate: nil, completed: false),
            ToDoItem(id: 2, title: "Тестовая задача 2", description: nil, dueDate: nil, completed: true),
            ToDoItem(id: 1, title: "Тестовая задача 1", description: nil, dueDate: nil, completed: false),
            ToDoItem(id: 2, title: "Тестовая задача 2", description: nil, dueDate: nil, completed: true),
            ToDoItem(id: 1, title: "Тестовая задача 1", description: nil, dueDate: nil, completed: false),
            ToDoItem(id: 2, title: "Тестовая задача 2", description: nil, dueDate: nil, completed: true),
            ToDoItem(id: 1, title: "Тестовая задача 1", description: nil, dueDate: nil, completed: false),
            ToDoItem(id: 2, title: "Тестовая задача 2", description: nil, dueDate: nil, completed: true)
        ]
    }
}

struct ToDoItem: Identifiable {
    let id: Int
    let title: String
    let description: String?
    let dueDate: Date?
    var completed: Bool
}

class APIService {
    func fetchTasks() -> AnyPublisher<[ToDoItem], Error> {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [APIResponse].self, decoder: JSONDecoder())
            .map { response in
                response.map { ToDoItem(
                    id: $0.id,
                    title: $0.title,
                    description: nil,
                    dueDate: nil,
                    completed: $0.completed
                ) }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct APIResponse: Codable {
    let id: Int
    let title: String
    let completed: Bool
}

class CoreDataManager {
    func saveTasks(_ tasks: [ToDoItem]) {
        print("Сохранено: \(tasks)")
    }
}
