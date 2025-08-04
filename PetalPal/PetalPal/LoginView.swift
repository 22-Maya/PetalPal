import SwiftUI
import Charts
import SwiftData
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    // MARK: - New State Variable for Username
    @State private var username = ""
    @State private var isRegistering = false

    // A simple email validation helper function.
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    // MARK: - Updated Form Validation
    // The validation logic now includes the username field for registration.
    private var formIsValid: Bool {
        if isRegistering {
            return !name.isEmpty && !username.isEmpty && !email.isEmpty && !password.isEmpty && password.count >= 6 && isValidEmail(email)
        } else {
            return !email.isEmpty && !password.isEmpty && password.count >= 6 && isValidEmail(email)
        }
    }

    var body: some View {
        VStack {
            Spacer()
          
            Text("PetalPal")
                .font(.custom("Prata-Regular", size: 40))
                .foregroundColor(Color(.tealShade))
                .padding(.bottom, 40)

            if isRegistering {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color(.backgroundShade))
                    .cornerRadius(10)
                    .autocapitalization(.words)
                    .padding(.horizontal)
                
                // MARK: - Username TextField
                // This field is only shown during registration.
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.backgroundShade))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .padding(.horizontal)
            }
          
            TextField("Email", text: $email)
                .padding()
                .background(Color(.backgroundShade))
                .cornerRadius(10)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
          
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.backgroundShade))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
          
            // Validation messages
            if email.isEmpty && !password.isEmpty {
                Text("Please enter an email address")
                    .foregroundColor(.orange)
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            } else if password.isEmpty && !email.isEmpty {
                Text("Please enter a password")
                    .foregroundColor(.orange)
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            } else if !password.isEmpty && password.count < 6 {
                Text("Password must be at least 6 characters")
                    .foregroundColor(.orange)
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            } else if let errorMessage = authViewModel.errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            }
          
            Button(action: {
                print("Button tapped! Email: \(email), Password length: \(password.count), IsRegistering: \(isRegistering)")
                // Add haptic feedback to confirm button tap
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
              
                Task {
                    authViewModel.errorMessage = nil
                  
                    guard !email.isEmpty, !password.isEmpty else {
                        authViewModel.errorMessage = "Please enter an email and password."
                        return
                    }
                  
                    if password.count < 6 {
                        authViewModel.errorMessage = "Password must be at least 6 characters long."
                        return
                    }

                    if isRegistering {
                        // MARK: - Updated Register Function Call
                        // The register function now passes the username.
                        await authViewModel.register(email: email, password: password, name: name, username: username)
                    } else {
                        await authViewModel.login(email: email, password: password)
                    }
                }
            }) {
                Text(isRegistering ? "Register" : "Log In")
                    .font(.custom("Lato-Bold", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(formIsValid ? Color(.blueShade) : Color.gray.opacity(0.5))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 10)
            .disabled(!formIsValid)
            .contentShape(Rectangle())
          
            Button(action: {
                isRegistering.toggle()
                authViewModel.errorMessage = nil
                email = ""
                password = ""
                name = ""
                // MARK: - Clear Username Field
                // Clears the username field when toggling modes.
                username = ""
            }) {
                Text(isRegistering ? "Already have an account? Log In" : "Don't have an account? Register here.")
                    .font(.custom("Lato-Regular", size: 16))
                    .foregroundColor(Color(.tealShade))
                    .padding(.top, 10)
            }
            .padding(.bottom, 20)
          
            Spacer()
        }
        .background(Color(red: 249/255, green: 248/255, blue: 241/255).ignoresSafeArea())
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
