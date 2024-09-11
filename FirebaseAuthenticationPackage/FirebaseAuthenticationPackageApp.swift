//
//  FirebaseAuthenticationPackageApp.swift
//  FirebaseAuthenticationPackage
//
//  Created by Sage Lewis on 9/11/24.
//

import SwiftUI
import FirebaseCore
import CoreData

@main
struct FirebaseAuthenticationPackageApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @AppStorage("uid") var userID: String = ""
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if userID.isEmpty {
                AuthView()
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
