//
//  AuthView.swift
//  SwiftUI-Auth
//
//  Created by Derek Hsieh on 1/7/23.
//

import SwiftUI

struct AuthView: View {
    @State private var currentViewShowing: String = "login" // or "signup"
    @AppStorage("uid") var userID: String = ""
    
    var body: some View {
        if currentViewShowing == "login" {
            LoginView(currentShowingView: $currentViewShowing)
        } else {
            SignupView(currentShowingView: $currentViewShowing)
        }
    }
}

#Preview {
    AuthView()
}
