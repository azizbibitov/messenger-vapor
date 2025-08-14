import SwiftUI

struct HomeView: View {
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Welcome, \(authVM.currentUser?.username ?? "")")
                .font(.title2)
            Button("Logout") { authVM.logout() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    HomeView(authVM: AuthViewModel())
}

