import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthViewModel
    var onSignUp: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up").font(.largeTitle).bold()

            TextField("Username", text: $viewModel.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button(action: { onSignUp?() }) {
                if viewModel.isLoading { ProgressView() } else { Text("Create Account").bold() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
        }
        .padding()
    }
}

#Preview {
    SignUpView(viewModel: AuthViewModel())
}

