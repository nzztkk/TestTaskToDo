import Foundation
import Combine

struct TodoAPIItem: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}

struct TodosResponse: Codable {
    let todos: [TodoAPIItem]
}



class ToDoAPIService {
    static let shared = ToDoAPIService()
    
    private init() {}
    
    func fetchTasks() -> AnyPublisher<[ToDoItem], Error> {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TodosResponse.self, decoder: JSONDecoder())
            .map { response in
                response.todos.map {
                    ToDoItem(
                        id: $0.id,
                        title: $0.todo,
                        description: nil,
                        dueDate: nil,
                        completed: $0.completed
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
}
