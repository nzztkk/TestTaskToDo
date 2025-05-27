import SwiftUI

struct ToDoListView: View {
    @ObservedObject var controller: ToDoListViewController

    @State private var searchText: String = ""
    @State private var navigateToCreate: Bool = false
    @State private var editingTask: ToDoItem? = nil

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Список задач")) {
                    ForEach(filteredTasks) { task in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .top) {
                                Button(action: {
                                    controller.toggleTaskCompletion(task)
                                }) {
                                    Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.completed ? .yellow : .gray)
                                        .imageScale(.large)
                                }
                                .buttonStyle(PlainButtonStyle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title)
                                        .font(.headline)
                                        .foregroundColor(task.completed ? .gray : .primary)
                                        .strikethrough(task.completed)

                                    if let desc = task.description, !desc.isEmpty {
                                        Text(desc)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    if let date = task.dueDate {
                                        Text("Срок: \(dateFormatter.string(from: date))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .contextMenu {
                            Button("Редактировать", systemImage: "pencil") {
                                editingTask = task
                                controller.prepareForEditing(task)
                                navigateToCreate = true
                            }

                            Button("Удалить", systemImage: "trash") {
                                controller.deleteTask(task)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Задачи")
            .searchable(text: $searchText, prompt: "Поиск задач...")
            .background(
                NavigationLink(
                    destination: ToDoCreateView(controller: controller, editingTask: $editingTask),
                    isActive: $navigateToCreate
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Text("\(filteredTasks.count) зада\(ending(for: filteredTasks.count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            editingTask = nil
                            controller.prepareForNewTask()
                            navigateToCreate = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.yellow)
                                .padding()
                        }
                    }
                }
            }
        }
    }

    var filteredTasks: [ToDoItem] {
        if searchText.isEmpty {
            return controller.tasks
        } else {
            return controller.tasks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func ending(for count: Int) -> String {
        let rem100 = count % 100
        let rem10 = count % 10
        if rem100 >= 11 && rem100 <= 14 {
            return "ч"
        }
        switch rem10 {
        case 1: return "ча"
        case 2...4: return "чи"
        default: return "ч"
        }
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(controller: ToDoListViewController())
    }
}
