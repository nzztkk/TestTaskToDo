import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "Test_EffectiveMobile")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Ошибка загрузки хранилища: \(error)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    func saveTask(_ task: ToDoItem) {
        let context = backgroundContext()
        context.perform {
            let cdTask = CDToDoItem(context: context)
            cdTask.id = Int64(task.id)
            cdTask.title = task.title
            cdTask.taskDescription = task.description
            cdTask.dueDate = task.dueDate
            cdTask.completed = task.completed

            do {
                try context.save()
            } catch {
                print("❌ Ошибка сохранения новой задачи: \(error)")
            }
        }
    }

    func updateTask(_ task: ToDoItem) {
        let context = backgroundContext()
        context.perform {
            let request: NSFetchRequest<CDToDoItem> = CDToDoItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", task.id)

            do {
                if let cdTask = try context.fetch(request).first {
                    cdTask.title = task.title
                    cdTask.taskDescription = task.description
                    cdTask.dueDate = task.dueDate
                    cdTask.completed = task.completed
                    try context.save()
                }
            } catch {
                print("❌ Ошибка обновления задачи: \(error)")
            }
        }
    }

    func deleteTask(_ task: ToDoItem) {
        let context = backgroundContext()
        context.perform {
            let request: NSFetchRequest<CDToDoItem> = CDToDoItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", task.id)

            do {
                if let cdTask = try context.fetch(request).first {
                    context.delete(cdTask)
                    try context.save()
                }
            } catch {
                print("❌ Ошибка удаления задачи: \(error)")
            }
        }
    }

    func loadTasks(completion: @escaping ([ToDoItem]) -> Void) {
        let context = backgroundContext()
        context.perform {
            let request: NSFetchRequest<CDToDoItem> = CDToDoItem.fetchRequest()

            do {
                let result = try context.fetch(request)
                let tasks = result.map { cdItem in
                    ToDoItem(
                        id: Int(cdItem.id),
                        title: cdItem.title ?? "",
                        description: cdItem.taskDescription,
                        dueDate: cdItem.dueDate,
                        completed: cdItem.completed
                    )
                }
                DispatchQueue.main.async {
                    completion(tasks)
                }
            } catch {
                print("Ошибка загрузки задач - \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    func syncTasksFromAPI(_ apiTasks: [ToDoItem], completion: @escaping () -> Void) {
        let context = backgroundContext()
        context.perform {
            let request: NSFetchRequest<CDToDoItem> = CDToDoItem.fetchRequest()

            do {
                let existing = try context.fetch(request)
                var existingDict = Dictionary(uniqueKeysWithValues: existing.map { (Int($0.id), $0) })

                for apiTask in apiTasks {
                    if let existing = existingDict[apiTask.id] {
                        if existing.title != apiTask.title ||
                            existing.taskDescription != apiTask.description ||
                            existing.dueDate != apiTask.dueDate ||
                            existing.completed != apiTask.completed {
                            
                            existing.title = apiTask.title
                            existing.taskDescription = apiTask.description
                            existing.dueDate = apiTask.dueDate
                            existing.completed = apiTask.completed
                        }
                    } else {
                        let newTask = CDToDoItem(context: context)
                        newTask.id = Int64(apiTask.id)
                        newTask.title = apiTask.title
                        newTask.taskDescription = apiTask.description
                        newTask.dueDate = apiTask.dueDate
                        newTask.completed = apiTask.completed
                    }
                }

                try context.save()
                DispatchQueue.main.async {
                    completion()
                }

            } catch {
                print("❌ Ошибка синхронизации задач: \(error)")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}
