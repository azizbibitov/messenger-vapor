//
//  ContentView.swift
//  MessengerLovestory
//
//  Created by Aziz Bibitov on 13/08/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            Group {
                if authVM.isAuthenticated {
                    HomeView(authVM: authVM)
                } else {
                    VStack(spacing: 24) {
                        LoginView(viewModel: authVM) {
                            Task { await authVM.performLogin() }
                        }
                        Button("Need an account? Sign Up") { showSignUp = true }
                            .buttonStyle(.borderless)
                    }
                    .navigationDestination(isPresented: $showSignUp) {
                        SignUpView(viewModel: authVM) {
                            Task { await authVM.performSignUp() }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(authVM: AuthViewModel())
}
