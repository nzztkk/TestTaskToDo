import XCTest
@testable import Test_EffectiveMobile

final class ToDoListViewControllerTests: XCTestCase {

    var controller: ToDoListViewController!

    override func setUpWithError() throws {
        super.setUp()
        controller = ToDoListViewController()
        
    }

    override func tearDownWithError() throws {
        controller = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertTrue(controller.tasks.isEmpty, "Задачи должны быть пустыми при инициализации")
        XCTAssertEqual(controller.newTaskTitle, "", "Название новой задачи должно быть пустым")
        XCTAssertEqual(controller.newTaskDescription, "", "Описание новой задачи должно быть пустым")
        XCTAssertNotNil(controller.newTaskDueDate, "Дата выполнения новой задачи должна быть инициализирована")
    }

    func testAddTask() {
        controller.newTaskTitle = "Тестовая задача"
        controller.newTaskDescription = "Это тестовое описание."
        controller.saveTask(existingTask: nil)

        XCTAssertEqual(controller.tasks.count, 1, "После сохранения должна быть одна задача")
        XCTAssertEqual(controller.tasks.first?.title, "Тестовая задача", "Название задачи должно совпадать")
        XCTAssertEqual(controller.tasks.first?.description, "Это тестовое описание.", "Описание задачи должно совпадать")
        XCTAssertFalse(controller.tasks.first?.completed ?? true, "Новая задача не должна быть выполнена")

        // Проверяем, что поля очищаются после сохранения новой задачи
        XCTAssertEqual(controller.newTaskTitle, "", "Название новой задачи должно быть очищено после сохранения")
        XCTAssertEqual(controller.newTaskDescription, "", "Описание новой задачи должно быть очищено после сохранения")
    }

    func testToggleTaskCompletion() {
        controller.newTaskTitle = "Переключаемая задача"
        controller.saveTask(existingTask: nil)
        
        guard let task = controller.tasks.first else {
            XCTFail("Задача должна существовать для переключения")
            return
        }

        XCTAssertFalse(task.completed, "Задача изначально должна быть невыполненной")

        controller.toggleTaskCompletion(task)
        XCTAssertTrue(controller.tasks.first?.completed ?? false, "Задача должна быть выполнена после переключения")

        controller.toggleTaskCompletion(task)
        XCTAssertFalse(controller.tasks.first?.completed ?? true, "Задача должна быть невыполненной после повторного переключения")
    }

    func testDeleteTask() {
        controller.newTaskTitle = "Задача для удаления"
        controller.saveTask(existingTask: nil)
        XCTAssertEqual(controller.tasks.count, 1, "До удаления должна быть одна задача")

        guard let taskToDelete = controller.tasks.first else {
            XCTFail("Задача должна существовать для удаления")
            return
        }

        controller.deleteTask(taskToDelete)
        XCTAssertTrue(controller.tasks.isEmpty, "Задачи должны быть пустыми после удаления")
    }

    func testPrepareForEditing() {
        // ИСПРАВЛЕНО: Добавлен id и изменен порядок аргументов dueDate и completed
        let originalTask = ToDoItem(id: 1, title: "Исходное название", description: "Исходное описание", dueDate: Date(), completed: false) // Строка 75
        controller.tasks.append(originalTask)

        controller.prepareForEditing(originalTask)

        XCTAssertEqual(controller.newTaskTitle, originalTask.title, "Название новой задачи должно быть установлено для редактирования")
        XCTAssertEqual(controller.newTaskDescription, originalTask.description, "Описание новой задачи должно быть установлено для редактирования")
        XCTAssertEqual(controller.newTaskDueDate, originalTask.dueDate, "Дата выполнения новой задачи должна быть установлена для редактирования")
    }

    func testSaveExistingTask() {
        // ИСПРАВЛЕНО: Добавлен id и изменен порядок аргументов dueDate и completed
        let initialTask = ToDoItem(id: 2, title: "Исходное название", description: "Исходное описание", dueDate: Date(), completed: false) // Строка 86
        controller.tasks.append(initialTask)

        controller.newTaskTitle = "Обновленное название"
        controller.newTaskDescription = "Обновленное описание"
        // Обновите dueDate, если ваш контроллер позволяет его редактировать
        let newDueDate = Date().addingTimeInterval(3600 * 24) // Завтра
        controller.newTaskDueDate = newDueDate

        controller.saveTask(existingTask: initialTask)

        XCTAssertEqual(controller.tasks.count, 1, "Количество задач должно оставаться 1 после редактирования")
        XCTAssertEqual(controller.tasks.first?.title, "Обновленное название", "Название задачи должно быть обновлено")
        XCTAssertEqual(controller.tasks.first?.description, "Обновленное описание", "Описание задачи должно быть обновлено")
        // Проверьте дату выполнения, если она является частью процесса редактирования
        XCTAssertEqual(controller.tasks.first?.dueDate, newDueDate, "Дата выполнения задачи должна быть обновлена")

        // Убедитесь, что поля новой задачи очищены
        XCTAssertEqual(controller.newTaskTitle, "", "Название новой задачи должно быть очищено после сохранения изменений")
        XCTAssertEqual(controller.newTaskDescription, "", "Описание новой задачи должно быть очищено после сохранения изменений")
    }

    func testCancelCreate() {
        controller.newTaskTitle = "Черновая задача"
        controller.newTaskDescription = "Некоторое черновое описание"
        
        controller.cancelCreate()
        
        XCTAssertEqual(controller.newTaskTitle, "", "Название новой задачи должно быть очищено при отмене")
        XCTAssertEqual(controller.newTaskDescription, "", "Описание новой задачи должно быть очищено при отмене")
    }

    func testPrepareForNewTask() {
        // Имитируем некоторые существующие черновые данные
        controller.newTaskTitle = "Предыдущий черновик"
        controller.newTaskDescription = "Предыдущее описание"

        controller.prepareForNewTask()

        XCTAssertEqual(controller.newTaskTitle, "", "Название новой задачи должно быть очищено для новой задачи")
        XCTAssertEqual(controller.newTaskDescription, "", "Описание новой задачи должно быть очищено для новой задачи")
        // Предполагая, что newTaskDueDate устанавливается в Date() в prepareForNewTask, вы можете проверить его близость
        XCTAssertNotNil(controller.newTaskDueDate, "Дата выполнения новой задачи должна быть установлена для новой задачи")
    }
}
