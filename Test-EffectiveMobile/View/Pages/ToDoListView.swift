import SwiftUI

struct ToDoListView: View {
    @ObservedObject var controller: ToDoListViewController
    
    @State private var navigateToAddTask: Bool = false
    @State private var searchText: String = ""
    @State private var prompt: String = "Поиск задач..."
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredTasks) { task in
                    Text(task.title)
                }
            }
            .navigationTitle("Задачи")
            .searchable(text: $searchText, prompt: prompt)
            .background(
                NavigationLink(destination: ToDoCreateView(controller: controller), isActive: $navigateToAddTask) {
                    EmptyView()
                }
                .hidden()
            )
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    VStack(spacing: 0) {
                        
                        
                        HStack {
                            Spacer()
                            
                            Text("\(filteredTasks.count) зада\(ending(for: filteredTasks.count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                navigateToAddTask = true
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
    
    var filteredTasks: [ToDoItem] {
        if searchText.isEmpty {
            return controller.tasks
        } else {
            return controller.tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(controller: ToDoListViewController())
    }
}
