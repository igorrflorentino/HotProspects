//
//  EditProspectView.swift
//  HotProspects
//
//  Created by Igor Florentino on 31/07/24.
//

import SwiftUI
import SwiftData

struct EditProspectView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.modelContext) var modelContext
	@Bindable var prospect: Prospect
	@State private var name: String
	@State private var emailAddress: String
	@State private var isContacted: Bool
	
	init(prospect: Prospect) {
		self.prospect = prospect
		self._name = State(initialValue: prospect.name)
		self._emailAddress = State(initialValue: prospect.emailAddress)
		self._isContacted = State(initialValue: prospect.isContacted)
	}
	
	var body: some View {
		Form {
			Section(header: Text("Prospect Details")) {
				TextField("Name", text: $name)
				TextField("Email", text: $emailAddress)
				Toggle("Contacted", isOn: $isContacted)
			}
			Button("Save") {
				saveProspect()
			}
		}
		.navigationTitle("Edit Prospect")
	}
	
	func saveProspect() {
		do {
			prospect.name = name
			prospect.emailAddress = emailAddress
			prospect.isContacted = isContacted
			try modelContext.save()
			dismiss()
		} catch {
			print("Failed to save prospect: \(error.localizedDescription)")
		}
	}
}

struct EditProspectView_Previews: PreviewProvider {
	static var previews: some View {
		// Create an in-memory model configuration
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		
		// Initialize the model container
		let container = try! ModelContainer(for: Prospect.self, configurations: config)
		
		// Create a sample prospect
		let sampleProspect = Prospect(name: "John Doe", emailAddress: "john.doe@example.com", isContacted: false)
		
		// Insert the sample prospect into the model context
		container.mainContext.insert(sampleProspect)
		
		return EditProspectView(prospect: sampleProspect)
			.modelContainer(container)
	}
}
