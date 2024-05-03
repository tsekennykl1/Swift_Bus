//
//  TodosView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 7/6/2024.
//

import Foundation
import SwiftUI

struct TodosView: View {
    @EnvironmentObject var toDoStore: TodosStore
    @State private var draft: String = ""

    var body: some View {
        NavigationView {
            List {
                TextField("Type something...", text: $draft, onCommit: addTodo)
                ForEach(toDoStore.todos.indexed(), id: \.1.id) { index, _ in
                    TodoItemView(todo: self.$toDoStore.todos[index])
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle("Todos")
        }
    }

    private func delete(_ indexes: IndexSet) {
        toDoStore.todos.remove(atOffsets: indexes)
    }

    private func move(_ indexes: IndexSet, to offset: Int) {
        toDoStore.todos.move(fromOffsets: indexes, toOffset: offset)
    }

    private func addTodo() {
        let newTodo = Todo(title: draft, date: Date(), isDone: false, priority: 0)
        toDoStore.todos.insert(newTodo, at: 0)
        draft = ""
    }
    
    struct TodoItemView: View {
        let todo: Binding<Todo>

        var body: some View {
            HStack {
                Toggle(isOn: todo.isDone) {
                    Text(todo.title.wrappedValue)
                        .strikethrough(todo.isDone.wrappedValue)
                }
            }
        }
    }
}
