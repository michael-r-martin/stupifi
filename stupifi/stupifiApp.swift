//
//  stupifiApp.swift
//  stupifi
//
//  Created by Michael Martin on 30/03/2022.
//

import SwiftUI

@main
struct stupifiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
