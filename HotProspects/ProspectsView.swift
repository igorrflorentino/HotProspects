//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Igor Florentino on 31/07/24.
//

import SwiftUI
import SwiftData
import CodeScanner
import UserNotifications

struct ProspectsView: View {
	enum FilterType {
		case none, contacted, uncontacted
	}
	
	enum SortType {
		case name, date
	}
	
	let filter: FilterType
	
	var title: String {
		switch filter {
		case .none:
			return "Everyone"
		case .contacted:
			return "Contacted people"
		case .uncontacted:
			return "Uncontacted people"
		}
	}
	
	@Query private var prospects: [Prospect] = []
	@Environment(\.modelContext) var modelContext
	@State private var isShowingScanner = false
	@State private var selectedProspects = Set<Prospect>()
	@State private var sortType: SortType = .name
	
	init(filter: FilterType, sort: SortDescriptor<Prospect>) {
		self.filter = filter
		
		if filter != .none {
			let showContactedOnly = filter == .contacted
			
			_prospects = Query(filter: #Predicate {
				$0.isContacted == showContactedOnly
			}, sort: [sort])
		} else {
			_prospects = Query(sort: [sort])
		}
	}
		
	var body: some View {
		NavigationStack {
			List(prospects, selection: $selectedProspects) { prospect in
				NavigationLink {
					EditProspectView(prospect: prospect)
				} label: {
					HStack {
						VStack(alignment: .leading) {
							Text(prospect.name)
								.font(.headline)
							Text(prospect.emailAddress)
								.foregroundStyle(.secondary)
						}
						
						if filter == .none && prospect.isContacted {
							Spacer()
							Image(systemName: "checkmark.circle.fill")
						}
					}
				}
				.onAppear {
					selectedProspects = []
				}
				.swipeActions {
					Button("Delete", systemImage: "trash", role: .destructive) {
						modelContext.delete(prospect)
					}
					if prospect.isContacted {
						Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
							prospect.isContacted.toggle()
						}
						.tint(.blue)
					} else {
						Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
							prospect.isContacted.toggle()
						}
						.tint(.green)
						Button("Remind Me", systemImage: "bell") {
							addNotification(for: prospect)
						}
						.tint(.orange)
					}
				}
				.tag(prospect)
			}
			.navigationTitle(title)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					EditButton()
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button("Scan", systemImage: "qrcode.viewfinder") {
						isShowingScanner = true
					}
				}
				if !selectedProspects.isEmpty {
					ToolbarItem(placement: .bottomBar) {
						Button("Delete Selected", action: delete)
					}
				}
			}
			.sheet(isPresented: $isShowingScanner) {
				CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
			}
		}
	}
	
	func handleScan(result: Result<ScanResult, ScanError>) {
		isShowingScanner = false
		switch result {
		case .success(let result):
			let details = result.string.components(separatedBy: "\n")
			guard details.count == 2 else { return }
			
			let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
			modelContext.insert(person)
			
		case .failure(let error):
			print("Scanning failed: \(error.localizedDescription)")
		}
	}
	
	func delete() {
		for prospect in selectedProspects {
			modelContext.delete(prospect)
		}
	}
	
	func addNotification(for prospect: Prospect) {
		let center = UNUserNotificationCenter.current()
		
		let addRequest = {
			let content = UNMutableNotificationContent()
			content.title = "Contact \(prospect.name)"
			content.subtitle = prospect.emailAddress
			content.sound = UNNotificationSound.default
			
			var dateComponents = DateComponents()
			dateComponents.hour = 9
			//let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
			
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			center.add(request)
		}
		
		center.getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				addRequest()
			} else {
				center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
					if success {
						addRequest()
					} else if let error {
						print(error.localizedDescription)
					}
				}
			}
		}
	}
}

struct ProspectsView_Previews: PreviewProvider {
	static var previews: some View {
		// Create an in-memory model configuration
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		
		// Initialize the model container
		let container = try! ModelContainer(for: Prospect.self, configurations: config)
		
		// Create a sample prospect
		let sampleProspect = Prospect(name: "John Doe", emailAddress: "john.doe@example.com", isContacted: false)
		
		// Insert the sample prospect into the model context
		container.mainContext.insert(sampleProspect)
		
		return ProspectsView(filter: .none, sort: SortDescriptor(\Prospect.name))
			.modelContainer(container)
	}
}
