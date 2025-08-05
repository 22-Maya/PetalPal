import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var newTask: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Tasks")
                .scaledFont("Lato-Bold", size: 25)
                .padding(.bottom, 5)
            
            List {
                ForEach(authViewModel.tasks) { task in
                    HStack {
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
            // MODIFIED: Added a frame to give the list a defined height.
            // This allows it to render correctly inside the VStack.
            .frame(height: 200)
            
            HStack {
                TextField("Add a new task...", text: $newTask)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(.greenShade))
                }
                .disabled(newTask.isEmpty)
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
        }
        .padding() // Add overall padding to the VStack
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.info))
        )
    }
    
    func addTask() {
        guard !newTask.isEmpty else { return }
        authViewModel.addTask(name: newTask)
        newTask = ""
    }
    
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = authViewModel.tasks[index]
            authViewModel.deleteTask(task: task)
        }
    }
}
