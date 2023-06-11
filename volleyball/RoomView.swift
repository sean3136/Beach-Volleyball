//
//  RoomView.swift
//  volleyball
//
//  Created by 李炘杰 on 2023/6/9.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct RoomView: View {
    @State private var roomcode = ""
    @State private var navigatetomain = false
    @State private var isJoin = false
    @State private var showstr = ""
    @State private var foundRoomCode: String = ""
    private let roomCollection = Firestore.firestore().collection("rooms")
    
    var body: some View {
        VStack {
            if (isJoin) {
                WaitView2(joinCode: foundRoomCode)
            }
            else if(navigatetomain){
                MainView(navigatetogameview: false, navigatetoroomview: false, navigatetologinview: false)
            }
            else {
                createJoin()
            }
        }
    }
    
    func createJoin() -> some View {
        ZStack {
            Image("bg")
            Button(action: {
                navigatetomain = true
            }) {
                Text("Back")
                    .font(.title)
                    .padding()
                    .background(Color(hue: 0.322, saturation: 0.75, brightness: 1.0))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .offset(x:-350,y:-125)
            VStack {
                TextField("Please type in room code", text: $roomcode, prompt: Text("Room code"))
                    .autocapitalization(.none)
                    .frame(width: 200)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .cornerRadius(10)
                
                Button(action: {
                    joinRoom()
                }) {
                    Text("Join")
                        .frame(height: 15)
                        .font(.title)
                        .padding()
                        .background(Color(hue: 0.449, saturation: 0.865, brightness: 0.966))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Text(showstr)
            }
        }
    }
    
    private func joinRoom() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        roomCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching rooms:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No rooms found")
                showstr = "Room not found"
                return
            }
            
            if documents.first(where: { $0.documentID == roomcode }) != nil {
                isJoin = true
                foundRoomCode = roomcode
                if let document = documents.first {
                    let documentID = document.documentID
                    roomCollection.document(documentID).setData(["joinBy": user.uid], merge: true)
                } else {
                    print("No documents found")
                }
            } else {
                print("Room not found")
                showstr = "Room not found"
            }
        }
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
