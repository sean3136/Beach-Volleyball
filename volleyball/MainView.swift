//
//  MainView.swift
//  volleyball
//
//  Created by 李炘杰 on 2023/6/9.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MainView: View {
    @State var navigatetogameview:Bool
    @State var navigatetoroomview:Bool
    @State var navigatetologinview:Bool
    @State private var roomCode: String = ""
    private let roomCollection = Firestore.firestore().collection("rooms")
    var body: some View {
        VStack {
            if(navigatetogameview) {
                WaitView()
            }
            else if(navigatetoroomview){
                RoomView()
            }
            else if(navigatetologinview) {
                LoginView()
            }
            else{
                createButton()
            }
            
        }
        
    }
    
    func createButton() -> some View {
        ZStack{
            Image("bg")
            VStack{
                Button(action: {
                    createGame()
                    navigatetogameview = true
                    navigatetoroomview = false
                }) {
                    Text("Create Game")
                        .font(.largeTitle)
                        .padding()
                        .background(Color(hue: 0.545, saturation: 0.679, brightness: 0.978))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    navigatetogameview = false
                    navigatetoroomview = true
                }) {
                    Text("Join Game")
                        .font(.largeTitle)
                        .padding()
                        .background(Color(hue: 0.735, saturation: 0.636, brightness: 0.99))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                }
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .font(.largeTitle)
                        .padding()
                        .background(Color(hue: 0.945, saturation: 0.754, brightness: 1.0))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            navigatetologinview = true
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func createGame() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        let codeLength = 4
        let code = generateRoomCode(length: codeLength)
        roomCode = code
        let roomData: [String: Any] = [
            "joinCode": code,
            "createdBy": user.uid
        ]
        
        roomCollection.document(code).setData(roomData) { error in
            if let error = error {
                print("Error creating game:", error.localizedDescription)
            } else {
                print("Game created successfully. Room code:", code)
                navigatetoroomview = true
            }
        }
    }
    
    private func generateRoomCode(length: Int) -> String {
        let characters = "0123456789"
        var code = ""
        for _ in 0..<length {
            if let character = characters.randomElement() {
                code.append(character)
            }
        }
        return code
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(navigatetogameview: false, navigatetoroomview: false, navigatetologinview: false)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
