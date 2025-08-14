import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onLogin: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text("Log In").font(.largeTitle).bold()

            TextField("Username", text: $viewModel.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button(action: { onLogin?() }) {
                if viewModel.isLoading { ProgressView() } else { Text("Log In").bold() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
        }
        .padding()
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}

