import SwiftUI

struct LoginView: View {
    @Binding var loggedIn: Bool
    
    @State var email: String = ""
    @State var password: String = ""
    @State var errorMessage: String?
    
    
    @EnvironmentObject var loggedInUser: LoggedUser
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                Image(.listSplit)
                
                // Subtitle
                Text("Manage your shopping list and\nsettle expenses with others.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
                    .padding(.bottom, 40)
                
                // Input Fields
                VStack(alignment: .leading, spacing: 8) {
                    Section(header: Text("Email").foregroundColor(.gray)) {
                        TextField("", text: $email)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5.0)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                    }

                    
                    Section(header: Text("Password").foregroundColor(.gray)) {
                        
                        
                        SecureField("", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5.0)
                    }
                }
                .padding(.horizontal, 30)
                
                // Forgot Password
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Text("Forgot password?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 30)
                }
                .padding(.top, 10)
                
                // Log in Button
                Button(action: handleLogin) {
                    Text("Log in")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 10)
                }
                
                // Sign Up
                HStack {
                    Text("Don't have an account? ")
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: RegistrationView()) {
                        Text("Sign up")
                    }
                    
                    
                }
                .padding(.top, 20)
                
                Spacer()
            }
        }
        
    }
    
    private func handleLogin() {
        if email == "" || password == "" {
            errorMessage = "Please fill in all fields."
            return
        }
        
        errorMessage = nil
        
        let loginData = LoginData(email: email, password: password)
        
        guard let body = try? JSONEncoder().encode(loginData) else { return }
        
        APIController.shared.performRequest(
            endpoint: "login",
            method: "POST",
            body: body
        ) {   (result: APIResponse<User>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    loggedIn = true
                    loggedInUser.email = user.data.email
                    loggedInUser.name = user.data.name
                    loggedInUser.id = user.data.id ?? 0
                    
                    print("sucessfully logged in")
                    print("user name: \(user.data.name)")
                    
                    
                case .failure(_):
                    errorMessage = "Failed to query API"
                }
            }
        }

        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        @State var loggedIn = false
        LoginView(loggedIn: $loggedIn)
    }
}
