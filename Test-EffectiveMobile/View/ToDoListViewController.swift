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
    
    
    //API
    private let apiService = ToDoAPIService.shared
    
    
    
    //CoreData
    private let coreDataManager = CoreDataManager.shared
    
    func saveToCoreData(_ tasks: [ToDoItem]) {
        for task in tasks {
            coreDataManager.saveTask(task)
        }
    }
    
    func loadFromCoreData() {
        coreDataManager.loadTasks { loadedTasks in
            self.tasks = loadedTasks
        }
    }
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        isLoading = true
        apiService.fetchTasks()
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    // self.tasks = self.loadFallbackTasks()
                }
            }, receiveValue: { tasks in
                self.tasks = tasks
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
            id: Int(Date().timeIntervalSince1970), // уникальный ID на основе времени
            title: title,
            description: newTaskDescription.isEmpty ? nil : newTaskDescription,
            dueDate: isDueDateEnabled ? newTaskDueDate : nil,
            completed: false
        )
        tasks.append(newTask)
        coreDataManager.saveTask(newTask) // ← сохраняем одну задачу
        showCreateView = false
    }
    
    func deleteTask(_ task: ToDoItem) {
        DispatchQueue.global(qos: .background).async {
            self.coreDataManager.deleteTask(task)
            DispatchQueue.main.async {
                self.tasks.removeAll { $0.id == task.id }
            }
        }
    }

    func editTask(_ task: ToDoItem) {
        // Пример редактирования — показываем форму создания, но с уже заполненными данными
        newTaskTitle = task.title
        newTaskDescription = task.description ?? ""
        newTaskDueDate = task.dueDate
        isDueDateEnabled = task.dueDate != nil
        showCreateView = true

        // После редактирования можно либо обновить task.id (если ID уникален), либо по ID заменить
        // Это зависит от логики saveTask()
    }
    
    
    
   
}
