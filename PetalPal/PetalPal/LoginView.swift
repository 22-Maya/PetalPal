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

    // A simple email validation helper function.
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
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
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.backgroundShade))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
            
            if let errorMessage = authViewModel.errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top, 5)
            }
            
            Button(action: {
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
                ZStack {
                    Text(isRegistering ? "Register" : "Log In")
                        .font(.custom("Lato-Bold", size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.blueShade))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top, 20)
            
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
            
            Spacer()
        }
        .background(Color(red: 249/255, green: 248/255, blue: 241/255).ignoresSafeArea())
    }
}
