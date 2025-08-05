import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var newTask: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Tasks")
                .scaledFont("Lato-Bold", size: 25)
                .padding(.top, 20)
                .padding(.bottom, 5)
            
            List {
                ForEach(authViewModel.tasks) { task in
                    HStack {
                        // Checkbox to toggle the task's completion status.
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .primary)
                            .onTapGesture {
                                // This calls the function in the viewModel to update the task.
                                authViewModel.toggleTaskCompletion(task: task)
                            }
                        
                        Text(task.name)
                            .scaledFont("Lato-Regular", size: 18)
                            .strikethrough(task.isCompleted, color: .primary)
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .listStyle(.plain)
            
            HStack {
                // The TextField is bound to the `newTask` state variable.
                TextField("Add a new task...", text: $newTask)
                    .textFieldStyle(.roundedBorder)
                
                // The button to trigger adding the new task.
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(.greenShade))
                }
                // The button is disabled if the text field is empty.
                .disabled(newTask.isEmpty)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            .padding(.trailing, 10)
        }
        .padding(.leading, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.info))
        )
    }
    
    /// Calls the view model to add a new task to Firestore.
    func addTask() {
        // Ensure the task name is not empty.
        guard !newTask.isEmpty else { return }
        authViewModel.addTask(name: newTask)
        // Clear the text field after the task is added.
        newTask = ""
    }
    
    /// Calls the view model to delete tasks from the list.
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = authViewModel.tasks[index]
            authViewModel.deleteTask(task: task)
        }
    }
}
