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

    private var cancellables = Set<AnyCancellable>()

    private let apiService = ToDoAPIService.shared
    private let coreDataManager = CoreDataManager.shared

    init() {
        loadFromCoreData()
        loadTasksFromAPI()
    }

    func loadTasksFromAPI() {
        isLoading = true
        apiService.fetchTasks()
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }, receiveValue: { apiTasks in
                // Обновляем задачи в Core Data без создания дубликатов
                self.coreDataManager.syncTasksFromAPI(apiTasks) {
                    self.loadFromCoreData()
                }
            })
            .store(in: &cancellables)
    }

    func loadFromCoreData() {
        coreDataManager.loadTasks { loadedTasks in
            self.tasks = loadedTasks
            print("Загружено задач: \(loadedTasks.count), первая задача dueDate: \(loadedTasks.first?.dueDate ?? nil)")
        }
    }

    func toggleTaskCompletion(_ task: ToDoItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.completed.toggle()
            tasks[index] = updatedTask
            coreDataManager.updateTask(updatedTask)
        }
    }

    func presentCreateView() {
        prepareForNewTask()
        showCreateView = true
    }

    func cancelCreate() {
        showCreateView = false
    }

    func prepareForNewTask() {
        newTaskTitle = ""
        newTaskDescription = ""
        newTaskDueDate = nil
    }

    func prepareForEditing(_ task: ToDoItem) {
        newTaskTitle = task.title
        newTaskDescription = task.description ?? ""
        newTaskDueDate = task.dueDate
        showCreateView = true
    }

    func saveTask(existingTask: ToDoItem? = nil) {
        let title = newTaskTitle.isEmpty ? "Новая задача" : newTaskTitle

        let task = ToDoItem(
            id: existingTask?.id ?? Int(Date().timeIntervalSince1970),
            title: title,
            description: newTaskDescription.isEmpty ? nil : newTaskDescription,
            dueDate: newTaskDueDate, // Всегда используем newTaskDueDate, который установлен в ToDoCreateView
            completed: existingTask?.completed ?? false
        )

        if let _ = existingTask {
            coreDataManager.updateTask(task)
            tasks = tasks.map { $0.id == task.id ? task : $0 }
        } else {
            coreDataManager.saveTask(task)
            tasks.append(task)
        }

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
        prepareForEditing(task)
    }
}
