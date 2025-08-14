import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: MeResponse?

    private var cancellables = Set<AnyCancellable>()

    func clearError() { errorMessage = nil }

    @MainActor
    func restoreSession() async {
        guard let token = AuthManager.shared.token else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            currentUser = try await APIClient.shared.me(token: token)
            isAuthenticated = true
        } catch {
            AuthManager.shared.logout()
        }
    }

    @MainActor
    func logout() {
        AuthManager.shared.logout()
        currentUser = nil
        isAuthenticated = false
        username = ""
        password = ""
        errorMessage = nil
    }

    @MainActor
    func performLogin() async {
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            let res = try await APIClient.shared.login(username: username, password: password)
            AuthManager.shared.save(token: res.token)
            currentUser = try await APIClient.shared.me(token: res.token)
            isAuthenticated = true
        } catch {
            errorMessage = localized(error)
        }
        isLoading = false
    }

    @MainActor
    func performSignUp() async {
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await APIClient.shared.register(username: username, password: password)
            // Auto-login after sign up
            let res = try await APIClient.shared.login(username: username, password: password)
            AuthManager.shared.save(token: res.token)
            currentUser = try await APIClient.shared.me(token: res.token)
            isAuthenticated = true
        } catch {
            errorMessage = localized(error)
        }
        isLoading = false
    }

    private func localized(_ error: Error) -> String {
        if case let APIError.client(_, message) = error, let message { return message }
        return error.localizedDescription
    }
}

