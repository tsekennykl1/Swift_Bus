//
//  TodoStore.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 7/6/2024.
//

import Foundation
import Combine

struct Todo: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var date: Date
    var isDone: Bool
    var priority: Int
}

final class TodosStore: ObservableObject {
    @Published var todos: [Todo] = []
    
    func orderByDate() {
        todos.sort { $0.date < $1.date }
    }
    
    func orderByPriority() {
        todos.sort { $0.priority > $1.priority }
    }
    
    func removeCompleted() {
        todos.removeAll { $0.isDone }
    }
}
