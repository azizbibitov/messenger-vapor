//
//  MessengerLovestoryApp.swift
//  MessengerLovestory
//
//  Created by Aziz Bibitov on 13/08/2025.
//

import SwiftUI

@main
struct MessengerLovestoryApp: App {
    @StateObject private var authVM = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(authVM: authVM)
                .task { await authVM.restoreSession() }
        }
    }
}
