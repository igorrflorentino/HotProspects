//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Igor Florentino on 30/07/24.
//

import SwiftUI
import SwiftData

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
		}.modelContainer(for: Prospect.self)

    }
}
