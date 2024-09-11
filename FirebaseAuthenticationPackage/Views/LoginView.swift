//
//  LoginView.swift
//  SwiftUI-Auth
//
//  Created by Derek Hsieh on 1/7/23.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var showPasswordRequirements = false
    @State private var showingPasswordReset = false
    @State private var resetEmail = ""
    
    private func isValidPassword(_ password: String) -> Bool {
        // Firebase requires a minimum of 6 characters
        return password.count >= 6
    }
    
    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
            if let error = error {
                alertMessage = "Password reset failed: \(error.localizedDescription)"
            } else {
                alertMessage = "Password reset email sent. Please check your inbox."
            }
            showAlert = true
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Welcome Back!")
                                .font(.largeTitle)
                                .bold()
                            
                            Spacer()
                        }
                        .padding()
                        .padding(.top)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "mail")
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)  // This ensures no auto-capitalization
                            
                            Spacer()
                            
                            
                            if(email.count != 0) {
                                
                                Image(systemName: email.isValidEmail() ? "checkmark" : "xmark")
                                    .fontWeight(.bold)
                                    .foregroundColor(email.isValidEmail() ? .green : .red)
                            }
                            
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.black)
                            
                        )
                        
                        .padding()
                        
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "lock")
                                SecureField("Password", text: $password)
                                    .onChange(of: password) { _, _ in
                                        showPasswordRequirements = true
                                    }
                                
                                Spacer()
                                
                                if(password.count != 0) {
                                    Image(systemName: isValidPassword(password) ? "checkmark" : "xmark")
                                        .fontWeight(.bold)
                                        .foregroundColor(isValidPassword(password) ? .green : .red)
                                }
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(.black)
                            )
                            
                            if showPasswordRequirements && !isValidPassword(password) {
                                Text("Password must be at least 6 characters long.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            withAnimation {
                                self.currentShowingView = "signup"
                            }
                            
                            
                        }) {
                            Text("Don't have an account?")
                                .foregroundColor(.black.opacity(0.7))
                        }
                        
                        Spacer()
                        Spacer()
                        
                        
                        Button {
                            if isValidPassword(password) {
                                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                                    if let error = error as NSError? {
                                        print("Error signing in: \(error.localizedDescription)")
                                        print("Error code: \(error.code)")
                                        print("Error user info: \(error.userInfo)")
                                        
                                        switch error.code {
                                        case AuthErrorCode.wrongPassword.rawValue:
                                            alertMessage = "Incorrect password. Please try again."
                                        case AuthErrorCode.invalidEmail.rawValue:
                                            alertMessage = "Invalid email address. Please check and try again."
                                        case AuthErrorCode.userNotFound.rawValue:
                                            alertMessage = "No account found with this email. Please sign up."
                                        default:
                                            alertMessage = error.localizedDescription
                                        }
                                        showAlert = true
                                    } else {
                                        // Sign-in successful
                                        withAnimation {
                                            userID = authResult?.user.uid ?? ""
                                        }
                                    }
                                }
                            } else {
                                alertMessage = "Password must be at least 6 characters long."
                                showAlert = true
                            }
                        } label: {
                            Text("Sign In")
                                .foregroundColor(.white)
                                .font(.title3)
                                .bold()
                            
                                .frame(maxWidth: .infinity)
                                .padding()
                            
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black)
                                )
                                .padding(.horizontal)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        
                        Button(action: {
                            showingPasswordReset = true
                        }) {
                            Text("Forgot Password?")
                                .foregroundColor(.blue)
                        }
                        .padding(.top)
                        
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height - keyboardHeight)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                        let keyboardRectangle = keyboardFrame.cgRectValue
                        keyboardHeight = keyboardRectangle.height
                    }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingPasswordReset) {
                VStack(spacing: 20) {
                    Text("Reset Password")
                        .font(.title)
                        .padding()
                    
                    TextField("Enter your email", text: $resetEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)  // This prevents automatic capitalization
                        .keyboardType(.emailAddress)  // This sets the keyboard type to email
                        .padding()
                    
                    Button("Send Reset Link") {
                        resetPassword()
                        showingPasswordReset = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        showingPasswordReset = false
                    }
                    .foregroundColor(.red)
                }
                .padding()
            }
        }
    }
}



