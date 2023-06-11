//
//  WaitView2.swift
//  volleyball
//
//  Created by 李炘杰 on 2023/6/10.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct WaitView2: View {
    @State private var isPlayer1Ready: Bool = false
    @State private var isPlayer2Ready: Bool = false
    @State private var isRoomJoined: Bool = false
    @State private var navigatetomain = false
    @State private var player1Name: String = ""
    private let roomCollection = Firestore.firestore().collection("rooms")
    var joinCode: String
    
    var body: some View {
        VStack {
            if(navigatetomain) {
                MainView(navigatetogameview: false, navigatetoroomview: false, navigatetologinview: false)
            }
            else if(isPlayer1Ready && isPlayer2Ready) {
                GameView(joinCode: joinCode)
            }
            else {
                waitView()
            }
        }
    }
    
    private func waitView() -> some View {
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
                Text("Room Code:")
                    .font(.title)
                    .foregroundColor(.black)
                if isRoomJoined {
                    Text(joinCode)
                        .font(.title)
                        .foregroundColor(.black)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(.black)
                }
                HStack {
                    VStack {
                        Text("Player 1:")
                            .font(.title)
                            .foregroundColor(.black)
                        if (player1Name != "") {
                            Text(player1Name)
                                .font(.body)
                                .foregroundColor(.black)
                                .padding()
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .foregroundColor(.black)
                                .padding()
                        }
                        Text(isPlayer1Ready ? "Ready" : "Not Ready")
                            .font(.title)
                            .foregroundColor(isPlayer1Ready ? .green : .red)
                            .padding()
                    }
                    
                    
                    if isRoomJoined {
                        VStack {
                            Text("Player 2:")
                                .font(.title)
                                .foregroundColor(.black)
                            Text(Auth.auth().currentUser?.uid ?? "")
                                .font(.body)
                                .foregroundColor(.black)
                                .padding()
                            if isRoomJoined {
                                Text(isPlayer2Ready ? "Ready" : "Not Ready")
                                    .font(.title)
                                    .foregroundColor(isPlayer2Ready ? .green : .red)
                                    .padding()
                            }
                        }
                    }
                }
                
                if isRoomJoined {
                    Button(action: {
                        isPlayer2Ready.toggle()
                        updateReadyStatus(isReady: isPlayer2Ready, player: "isPlayer2Ready")
                    }) {
                        Text(isPlayer2Ready ? "Unready" : "Ready")
                            .font(.title)
                            .padding()
                            .background(isPlayer2Ready ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .onAppear {
            fetchJoinCode()
            checkChange()
        }
    }
    
    private func fetchJoinCode() {
        roomCollection.whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching join code:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first {
                    self.isRoomJoined = true
                    self.isPlayer1Ready = document["isPlayer1Ready"] as? Bool ?? false
                    self.isPlayer2Ready = document["isPlayer2Ready"] as? Bool ?? false
                    self.player1Name = document["createdBy"] as? String ?? ""
                    print(player1Name)
                }
            else {
                print("Room does not exist")
            }
            
        }
    }
    
    private func updateReadyStatus(isReady: Bool, player: String) {
        roomCollection.whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error updating ready status:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first {
                let documentID = document.documentID
                roomCollection.document(documentID).updateData([player: isReady])
            } else {
                print("No documents found")
            }
        }
    }
    
    private func checkChange() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        roomCollection
            .whereField("joinBy", isEqualTo: user.uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to room changes:", error.localizedDescription)
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("No snapshot found")
                    return
                }
                
                let documents = snapshot.documents
                
                if let document = documents.first, let joinCode = document["joinCode"] as? String {
                    self.isRoomJoined = true
                    self.isPlayer1Ready = document["isPlayer1Ready"] as? Bool ?? false
                    self.isPlayer2Ready = document["isPlayer2Ready"] as? Bool ?? false
                    self.player1Name = document["createdBy"] as? String ?? ""
                } else {
                    print("Room does not exist")
                }
            }
    }

}

struct WaitView2_Previews: PreviewProvider {
    static var previews: some View {
        WaitView2(joinCode: "YOUR_JOIN_CODE_HERE")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
