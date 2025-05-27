import SwiftUI

struct ToDoCreateView: View {
    @ObservedObject var controller: ToDoListViewController
    @Environment(\.dismiss) var dismiss
    
    let today = Date()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                
                // Имя задачи
                
                TextField("Новая задача", text: Binding(
                    get: { controller.newTaskTitle },
                    set: { controller.newTaskTitle = $0 }
                ))
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
                .padding(.top, 30)
                
                Spacer()
                
            
                
                
                // Выбор даты
                
                DatePicker("Дата", selection: Binding(
                    get: { controller.newTaskDueDate ?? today },
                    set: { controller.newTaskDueDate = $0 }
                ), in: today..., displayedComponents: [.date])
                .labelsHidden()
                .padding(.horizontal)
                .datePickerStyle(.compact)
                
                
                
                // Поле для описания
                TextEditor(text: Binding(
                    get: { controller.newTaskDescription },
                    set: { controller.newTaskDescription = $0 }
                ))
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
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )
                
               
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        controller.cancelCreate()
                    }
                    .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let title = controller.newTaskTitle.isEmpty ? "Новая задача" : controller.newTaskTitle
                        controller.newTaskTitle = title
                        controller.saveTask()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ToDoCreateView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoCreateView(controller: ToDoListViewController())
    }
}
