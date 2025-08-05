import SwiftUI

struct TodoListView: View {
    // MARK: - State Variables
    // This array will hold the list of tasks.
    @State private var tasks: [String] = ["Weed & prune plants", "Water plants"]
    // This will hold the text for the new task being added.
    @State private var newTask: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Tasks")
                .scaledFont("Lato-Bold", size: 25)
                .padding(.top, 20)
                .padding(.bottom, 5)
            
            // MARK: - Task List
            // The List view displays each task and supports deleting items.
            List {
                ForEach(tasks, id: \.self) { task in
                    Text(task)
                        .scaledFont("Lato-Regular", size: 18)
                }
                .onDelete(perform: deleteTask)
            }
            .listStyle(.plain) // Use a plain style to better match your design
            
            // MARK: - Add New Task UI
            // This HStack contains the TextField and Button for adding new tasks.
            HStack {
                TextField("Add a new task...", text: $newTask)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                }
                .disabled(newTask.isEmpty) // The button is disabled if the text field is empty
            }
            .padding(.top, 10)
        }
        .padding(.leading, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(red: 216/255, green: 232/255, blue: 202/255))
        )
        .padding(.horizontal, 30)
        .navigationBarItems(trailing: EditButton()) // Adds an Edit button to the navigation bar
    }
    
    // MARK: - Functions
    
    /// Adds the new task to the list and clears the text field.
    func addTask() {
        guard !newTask.isEmpty else { return }
        tasks.append(newTask)
        newTask = ""
    }
    
    /// Deletes a task from the list at the specified offsets.
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

#Preview {
    NavigationView {
        TodoListView()
            .environmentObject(TextSizeManager.shared)
    }
}
