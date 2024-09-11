//
//  FirebaseAuthenticationPackageApp.swift
//  FirebaseAuthenticationPackage
//
//  Created by Sage Lewis on 9/11/24.
//

import SwiftUI

@main
struct FirebaseAuthenticationPackageApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
