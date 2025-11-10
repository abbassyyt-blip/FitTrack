//
//  AuthView.swift
//  FitTrack Code
//
//  Authentication screen with login and registration
//

import SwiftUI

struct AuthView: View {
    @StateObject private var networkManager = NetworkManager.shared
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo/Title Section
                    VStack(spacing: 16) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 80))
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            .padding(.top, 60)
                        
                        Text("FitTrack")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                        
                        Text("Your Personal Lab for Progress")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7))
                    }
                    .padding(.bottom, 20)
                    
                    // Toggle between Login and Register
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                isLoginMode = true
                                clearFields()
                            }
                        }) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(isLoginMode ? .white : Color(red: 0.0, green: 0.5, blue: 1.0))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isLoginMode ? Color(red: 0.0, green: 0.5, blue: 1.0) : Color.clear)
                                .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                        }
                        
                        Button(action: {
                            withAnimation {
                                isLoginMode = false
                                clearFields()
                            }
                        }) {
                            Text("Register")
                                .font(.headline)
                                .foregroundColor(!isLoginMode ? .white : Color(red: 0.0, green: 0.5, blue: 1.0))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(!isLoginMode ? Color(red: 0.0, green: 0.5, blue: 1.0) : Color.clear)
                                .cornerRadius(10, corners: [.topRight, .bottomRight])
                        }
                    }
                    .background(Color("SecondaryBackground"))
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            
                            TextField("your@email.com", text: $email)
                                .textFieldStyle(AuthTextFieldStyle())
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .disabled(isLoading)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                            
                            SecureField("••••••••", text: $password)
                                .textFieldStyle(AuthTextFieldStyle())
                                .textContentType(isLoginMode ? .password : .newPassword)
                                .disabled(isLoading)
                        }
                        
                        // Confirm Password (only for registration)
                        if !isLoginMode {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                                
                                SecureField("••••••••", text: $confirmPassword)
                                    .textFieldStyle(AuthTextFieldStyle())
                                    .textContentType(.newPassword)
                                    .disabled(isLoading)
                            }
                        }
                        
                        // Error Message
                        if let error = errorMessage, showError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Submit Button
                        Button(action: {
                            handleSubmit()
                        }) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isLoginMode ? "Login" : "Create Account")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.0, green: 0.5, blue: 1.0))
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || !isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty && password.count >= 8
        } else {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   password.count >= 8 && 
                   password == confirmPassword &&
                   email.contains("@")
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
        showError = false
    }
    
    private func handleSubmit() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        Task {
            do {
                if isLoginMode {
                    _ = try await networkManager.login(email: email, password: password)
                } else {
                    _ = try await networkManager.register(email: email, password: password)
                }
                
                // Success - NetworkManager will update isAuthenticated
                await MainActor.run {
                    isLoading = false
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "An unexpected error occurred"
                    showError = true
                }
            }
        }
    }
}

// Custom text field style for auth
struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color("SecondaryBackground"))
            .cornerRadius(10)
            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
    }
}

#Preview {
    AuthView()
}

