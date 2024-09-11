//
//  SignupView.swift
//  SwiftUI-Auth
//
//  Created by Derek Hsieh on 1/7/23.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var showPasswordRequirements = false
    
    private func isValidPassword(_ password: String) -> Bool {
        // Firebase requires a minimum of 6 characters
        return password.count >= 6
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Create an Account!")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding()
                        .padding(.top)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "mail")
                            TextField("Email", text: $email)
                                .foregroundColor(.white)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)  // This ensures no auto-capitalization
                            
                            Spacer()
                            
                            if(email.count != 0) {
                                Image(systemName: email.isValidEmail() ? "checkmark" : "xmark")
                                    .fontWeight(.bold)
                                    .foregroundColor(email.isValidEmail() ? .green : .red)
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.white)
                        )
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "lock")
                                SecureField("Password", text: $password)
                                    .foregroundColor(.white)
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
                            .foregroundColor(.white)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(.white)
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
                                self.currentShowingView = "login"
                            }
                        }) {
                            Text("Already have an account?")
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        Spacer()
                        
                        Button {
                            if isValidPassword(password) {
                                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                                    if let error = error as NSError? {
                                        print("Error signing up: \(error.localizedDescription)")
                                        print("Error code: \(error.code)")
                                        print("Error user info: \(error.userInfo)")
                                        
                                        switch error.code {
                                        case AuthErrorCode.emailAlreadyInUse.rawValue:
                                            alertMessage = "Email already in use. Please use a different email or try logging in."
                                        case AuthErrorCode.invalidEmail.rawValue:
                                            alertMessage = "Invalid email address. Please check and try again."
                                        case AuthErrorCode.weakPassword.rawValue:
                                            alertMessage = "Password is too weak. Please choose a stronger password."
                                        default:
                                            alertMessage = error.localizedDescription
                                        }
                                        showAlert = true
                                    } else {
                                        // Sign-up successful
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
                            Text("Create Account")
                                .foregroundColor(.black)
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                )
                                .padding(.horizontal)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
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
        }
    }
}



