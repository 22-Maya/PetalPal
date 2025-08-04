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
    @State private var isRegistering = false

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private var formIsValid: Bool {
        return !email.isEmpty && !password.isEmpty && password.count >= 6 && isValidEmail(email)
    }

    var body: some View {
        VStack {
            Spacer()
          
            Text("PetalPal")
                .font(.custom("Prata-Regular", size: 40))
                .foregroundColor(Color(.tealShade))
                .padding(.bottom, 40)
          
            TextField("Email", text: $email)
                .padding()
                .background(Color(.backgroundShade))
                .cornerRadius(10)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.pinkShade), lineWidth: 2)
                )
                .padding()
          
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.backgroundShade))
                .cornerRadius(10)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.pinkShade), lineWidth: 2)
                )
                .padding()
          
            // Validation messages
            if email.isEmpty && !password.isEmpty {
                Text("Please enter an email address")
                    .foregroundColor(Color(red: 212/255, green: 106/255, blue: 106/255))
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            } else if password.isEmpty && !email.isEmpty {
                Text("Please enter a password")
                    .foregroundColor(Color(red: 212/255, green: 106/255, blue: 106/255))
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            } else if !password.isEmpty && password.count < 6 {
                Text("Password must be at least 6 characters")
                    .foregroundColor(Color(red: 212/255, green: 106/255, blue: 106/255))
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            } else if let errorMessage = authViewModel.errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(Color(red: 212/255, green: 106/255, blue: 106/255))
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            }
          
            Button(action: {
                print("Button tapped! Email: \(email), Password length: \(password.count), IsRegistering: \(isRegistering)")
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
                        await authViewModel.register(email: email, password: password)
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
            .background(formIsValid ? Color(red: 121/255, green: 175/255, blue: 169/255) : Color(.blueShade))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 10)
            // The button is disabled when the form is NOT valid.
            .disabled(!formIsValid)
            .contentShape(Rectangle())
          
            Button(action: {
                isRegistering.toggle()
                authViewModel.errorMessage = nil
                email = ""
                password = ""
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
