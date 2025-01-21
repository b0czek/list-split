//
//  RegistrationView.swift
//  ListSplit
//
//  Created by stud on 19/11/2024.
//

import SwiftUI


import SwiftUI

struct RegistrationView: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var errorMessage: String?
    @State private var registered: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(.listSplit)
            
            // Subtitle
            Text("Create an account to start managing\nshopping expenses with ListSplit.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.top, 2)
                .padding(.bottom, 40)
            
            // Input Fields
            VStack(alignment: .leading, spacing: 8) {
                Group {
                    Section(header: Text("Name").foregroundColor(.gray)) {

                        TextField("", text: $fullName)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5.0)
                    }


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
                    Section(header: Text("Repeat password").foregroundColor(.gray)) {
                        SecureField("", text: $confirmPassword)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5.0)
                    }
                }
            }
            .padding(.horizontal, 30)
            
            
            
            // Sign up Button
            Button(action: handleSignUp) {
                Text("Sign up")
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
            
            
            Spacer()
        }
        .navigationBarTitle("Sign up", displayMode: .inline)
        
    }
    
    
    private func handleSignUp() {
        
        errorMessage = nil
        if fullName == "" || email == "" || password == "" || confirmPassword == "" {
            errorMessage = "Please fill in all fields."
            return
        }
        

        
        if password == confirmPassword {
            
            let user = User(name: fullName, email: email, password: password)
            
            guard let body = try? JSONEncoder().encode(user) else { return }
            
            APIController.shared.performMessageRequest(
                endpoint: "register",
                method: "POST",
                body: body
            ) {   result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let res):
                        if res.statusCode == 201 {
                            dismiss()
                        } else {
                            errorMessage = res.data.message
                        }
                    case .failure(_):
                        errorMessage = "Failed to query API"
                    }
                }
            }
        } else {
            errorMessage = "Passwords do not match."
        }
        
        
        
    }
    
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}

