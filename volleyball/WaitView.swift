//
//  WaitView.swift
//  volleyball
//
//  Created by 李炘杰 on 2023/6/10.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct WaitView: View {
    @State private var isPlayer1Ready: Bool = false
    @State private var isPlayer2Ready: Bool = false
    @State private var joinCode: String = ""
    @State private var isRoomJoined: Bool = false
    @State private var navigatetomain = false
    @State private var player2Name: String = ""
    private let roomCollection = Firestore.firestore().collection("rooms")
    
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
                deleteRoomCollection()
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
                        Text(Auth.auth().currentUser?.uid ?? "")
                            .font(.body)
                            .foregroundColor(.black)
                            .padding()
                        if isRoomJoined {
                            Text(isPlayer1Ready ? "Ready" : "Not Ready")
                                .font(.title)
                                .foregroundColor(isPlayer1Ready ? .green : .red)
                                .padding()
                        }
                    }
                    
                    if isRoomJoined {
                        VStack {
                            Text("Player 2:")
                                .font(.title)
                                .foregroundColor(.black)
                            if (player2Name != "") {
                                Text(player2Name)
                                    .font(.body)
                                    .foregroundColor(.black)
                                    .padding()
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            Text(isPlayer2Ready ? "Ready" : "Not Ready")
                                .font(.title)
                                .foregroundColor(isPlayer2Ready ? .green : .red)
                                .padding()
                        }
                    }
                }
                
                if isRoomJoined {
                    Button(action: {
                        isPlayer1Ready.toggle()
                        updateReadyStatus(isReady: isPlayer1Ready, player: "isPlayer1Ready")
                    }) {
                        Text(isPlayer1Ready ? "Unready" : "Ready")
                            .font(.title)
                            .padding()
                            .background(isPlayer1Ready ? Color.red : Color.green)
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
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        roomCollection.whereField("createdBy", isEqualTo: user.uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching join code:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first, let joinCode = document["joinCode"] as? String {
                self.joinCode = joinCode
                self.isRoomJoined = true
                self.isPlayer1Ready = document["isPlayer1Ready"] as? Bool ?? false
                self.isPlayer2Ready = document["isPlayer2Ready"] as? Bool ?? false
                self.player2Name = document["joinBy"] as? String ?? ""
                print(player2Name)
            } else {
                print("Room does not exist")
            }
        }
        
    }
    
    private func updateReadyStatus(isReady: Bool, player: String) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        roomCollection.whereField("createdBy", isEqualTo: user.uid).getDocuments { snapshot, error in
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
    
    private func deleteRoomCollection() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        roomCollection.whereField("createdBy", isEqualTo: user.uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching room collection:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            for document in documents {
                document.reference.delete()
            }
            
            print("Room collection deleted")
        }
    }
    
    private func checkChange() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        roomCollection
            .whereField("createdBy", isEqualTo: user.uid)
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
                    self.joinCode = joinCode
                    self.isRoomJoined = true
                    self.isPlayer1Ready = document["isPlayer1Ready"] as? Bool ?? false
                    self.isPlayer2Ready = document["isPlayer2Ready"] as? Bool ?? false
                    self.player2Name = document["joinBy"] as? String ?? ""
                } else {
                    print("Room does not exist")
                }
            }
    }
}

struct WaitView_Previews: PreviewProvider {
    static var previews: some View {
        WaitView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
