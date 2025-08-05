import SwiftUI

struct TodoListView: View {
    // The view gets its data from the AuthViewModel.
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var newTask: String = ""

    var body: some View {
        // The ScrollView has been added to ensure content is scrollable if the list grows.
        ScrollView {
            VStack(alignment: .leading) {
                Text("Today's Tasks")
                    .scaledFont("Lato-Bold", size: 25)
                    .padding(.top, 20)
                    .padding(.bottom, 5)
                
                // The list iterates over the tasks from the view model.
                List {
                    ForEach(authViewModel.tasks) { task in
                        HStack {
                            // Checkbox to toggle completion status
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .primary)
                                .onTapGesture {
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
                
                // UI for adding a new task
                HStack {
                    TextField("Add a new task...", text: $newTask)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            // The button color has been updated.
                            .foregroundColor(Color(.greenShade))
                    }
                    .disabled(newTask.isEmpty)
                }
                .padding(.top, 10)
                // Padding has been updated to match your new style.
                .padding(.bottom, 20)
                .padding(.trailing, 10)
            }
            .padding(.leading, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    // The background color has been updated.
                    .fill(Color(.info))
            )
            .padding(.horizontal, 30)
            // The EditButton has been added to the navigation bar.
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    // Calls the view model to add a new task.
    func addTask() {
        guard !newTask.isEmpty else { return }
        authViewModel.addTask(name: newTask)
        newTask = ""
    }
    
    // Deletes tasks from the list.
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = authViewModel.tasks[index]
            authViewModel.deleteTask(task: task)
        }
    }
}

#Preview {
    NavigationView {
        TodoListView()
            .environmentObject(AuthViewModel())
            .environmentObject(TextSizeManager.shared)
    }
}
