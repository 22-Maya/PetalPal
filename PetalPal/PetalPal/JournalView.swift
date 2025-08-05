import SwiftUI
import FirebaseFirestore

struct JournalView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isAddingNote = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("PetalPal")
                        .scaledFont("Prata-Regular", size: 28)
                        .foregroundColor(Color(.tealShade))
                        .padding(.leading, 20)
                    Spacer()
                    NavigationLink {
                        HelpbotView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(.greenShade))
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 56)
                .background(Color(.blueShade))
                .padding(.bottom, 15)

                ScrollView {
                    VStack(spacing: 20) {
                        // The extra padding modifier has been removed from here.
                        
                        Button {
                            isAddingNote = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add New Note")
                            }
                            .scaledFont("Lato-Bold", size: 18)
                            .foregroundColor(Color(.tealShade))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.backgroundShade))
                                    .shadow(radius: 2)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20) // Padding is now correctly applied to the button.
                        
                        ForEach(authViewModel.journalEntries) { entry in
                            JournalEntryView(entry: entry)
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddingNote) {
                AddNoteView(isPresented: $isAddingNote)
            }
            .navigationBarBackButtonHidden(true)
            .foregroundStyle(Color(.text))
            .scaledFont("Lato-Regular", size: 20)
            .background(Color(.backgroundShade))
        }
    }
}

struct JournalEntryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.date.dateValue(), style: .date)
                    .scaledFont("Lato-Regular", size: 14)
                    .foregroundColor(Color(.text))
                Spacer()
                if let plantName = entry.plantName, !plantName.isEmpty {
                    Text(plantName)
                        .scaledFont("Lato-Bold", size: 14)
                        .foregroundColor(Color(.tealShade))
                }
                Button(role: .destructive, action: {
                    withAnimation {
                        authViewModel.deleteJournalEntry(entry: entry)
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(Color(.text))
                        .font(.system(size: 14))
                }
                .padding(.leading, 8)
            }
            
            Text(entry.content)
                .scaledFont("Lato-Regular", size: 16)
                .foregroundColor(Color(.text))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.pinkShade).opacity(0.15))
        )
        .padding(.horizontal)
    }
}

struct AddNoteView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool
    
    @State private var noteContent = ""
    @State private var plantName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note")
                    .scaledFont("Lato-Bold", size: 16)
                    .foregroundColor(Color(.tealShade))) {
                    TextEditor(text: $noteContent)
                        .frame(height: 150)
                }
                
                Section(header: Text("Related plant (optional)")
                    .scaledFont("Lato-Bold", size: 16)
                    .foregroundColor(Color(.tealShade))) {
                    // The plant picker has been replaced with a TextField.
                    TextField("Enter plant name", text: $plantName)
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(Color(.tealShade))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Saving is now handled by the AuthViewModel.
                        authViewModel.addJournalEntry(content: noteContent, plantName: plantName)
                        isPresented = false
                    }
                    .disabled(noteContent.isEmpty)
                    .foregroundColor(Color(.tealShade))
                }
            }
        }
    }
}

#Preview {
    JournalView()
        .environmentObject(AuthViewModel())
        .environmentObject(TextSizeManager.shared)
}
