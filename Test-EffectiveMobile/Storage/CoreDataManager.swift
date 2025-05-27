import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "Test_EffectiveMobile") // имя файла .xcdatamodeld
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
        
        let context = CoreDataManager.shared.backgroundContext()
        
        context.perform() {
            let request: NSFetchRequest<CDToDoItem> = CDToDoItem.fetchRequest()
            
            do {
                let result = try context.fetch(request)
                let tasks = result.map {cdItem in
                    ToDoItem(
                        id: Int(cdItem.id),
                        title: cdItem.title ?? "",
                        description: cdItem.description,
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
    
    
}
