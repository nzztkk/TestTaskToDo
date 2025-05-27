import SwiftUI

struct ToDoCreateView: View {
    @ObservedObject var controller: ToDoListViewController
    @Binding var editingTask: ToDoItem?
    @Environment(\.dismiss) var dismiss

    let today = Date()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Новая задача", text: $controller.newTaskTitle)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 30)

                Text("\(dateFormatter.string(from: today))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                TextEditor(text: $controller.newTaskDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .frame(minHeight: 200)
                    .overlay(
                        Group {
                            if controller.newTaskDescription.isEmpty {
                                Text("Запишите задачи здесь")
                                    .foregroundColor(.gray)
                                    .font(.body)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 12)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                    )

                Spacer()
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        controller.cancelCreate()
                        editingTask = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        controller.saveTask(existingTask: editingTask)
                        editingTask = nil
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            editingTask = nil
        }
        .onAppear {
            controller.newTaskDueDate = Date()
        }
    }
}

struct ToDoCreateView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoCreateView(controller: ToDoListViewController(), editingTask: .constant(nil))
    }
}
