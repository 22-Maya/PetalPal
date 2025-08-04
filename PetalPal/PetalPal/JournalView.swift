//
//  JournalView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @Query private var entries: [JournalEntry]
    
    @State private var newNote = ""
    @State private var selectedPlant: Plant?
    @State private var isAddingNote = false
    
    var body: some View {
        NavigationStack {
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
                        .foregroundColor(Color(.tealShade))
                        .padding(.trailing, 20)
                }
            }
            .frame(height: 56)
            .background(Color(.blueShade))
            .padding(.bottom, 15)

            ScrollView {
                VStack(spacing: 20) {
                    // Add Note Button
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
                    
                    // Journal Entries
                    ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
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

struct JournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .scaledFont("Lato-Regular", size: 14)
                    .foregroundColor(Color(.text))
                Spacer()
                if let plant = entry.plant {
                    Text(plant.name)
                        .scaledFont("Lato-Bold", size: 14)
                        .foregroundColor(Color(.tealShade))
                }
                Button(role: .destructive, action: {
                    withAnimation {
                        modelContext.delete(entry)
                        try? modelContext.save()
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
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @Binding var isPresented: Bool
    
    @State private var noteContent = ""
    @State private var selectedPlant: Plant?
    
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
                    Picker("Select Plant", selection: $selectedPlant) {
                        Text("None").tag(Plant?.none)
                        ForEach(plants) { plant in
                            Text(plant.name).tag(Plant?.some(plant))
                        }
                    }
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
                        let entry = JournalEntry(content: noteContent, plant: selectedPlant)
                        modelContext.insert(entry)
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
}
