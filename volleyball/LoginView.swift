//
//  LoginView.swift
//  volleyball
//
//  Created by 李炘杰 on 2023/6/10.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showstr = ""
    @State private var isLoggedIn = false
    
    var body: some View {
        VStack {
            if(checkLogin()) {
                MainView(navigatetogameview: false, navigatetoroomview: false, navigatetologinview: false)
            }
            else {
                loginView()
            }
        }
    }
    
    func loginView() -> some View {
        ZStack {
            Image("bg")
            VStack {
                TextField("Please type in your email", text: $email, prompt: Text("Email"))
                    .autocapitalization(.none)
                    .frame(width: 200)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .cornerRadius(10)
                TextField("Please type in your password", text: $password, prompt: Text("Password"))
                    .autocapitalization(.none)
                    .frame(width: 200)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .cornerRadius(10)
                HStack {
                    Button(action: {
                        signIn()
                    }) {
                        Text("Login")
                            .frame(height: 15)
                            .font(.title)
                            .padding()
                            .background(Color(hue: 0.449, saturation: 0.865, brightness: 0.966))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        register()
                    }) {
                        Text("Register")
                            .frame(height: 15)
                            .font(.title)
                            .padding()
                            .background(Color(hue: 0.449, saturation: 0.865, brightness: 0.966))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                Text(showstr)
            }
        }
    }
    
    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                showstr = error.localizedDescription
            } else {
                print("Success")
                isLoggedIn = true
            }
        }
    }
    
    private func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let user = result?.user,
                  error == nil else {
                print(error?.localizedDescription)
                showstr = String(error?.localizedDescription ?? "")
                return
            }
            print(user.email, user.uid)
            showstr = "Register success, please login again."
        }
    }
    
    
    private func checkLogin() -> Bool {
        if let user = Auth.auth().currentUser {
            print(user)
            return true
        } else {
            return false
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
