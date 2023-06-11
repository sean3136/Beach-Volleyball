//
//  GameView.swift
//  volleyball
//
//  Created by 李炘杰 on 2023/6/9.
//

import SwiftUI
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct GameView: View {
    @State private var player1Name: String = ""
    @State private var player2Name: String = ""
    @State private var player1Score: Int = 0
    @State private var player2Score: Int = 0
    @State private var player1Xcor: Double = -335.0
    @State private var player2Xcor: Double = 335.0
    @State private var currentPlayer: String = ""
    @State private var ballXcor: Double = -240.0
    @State private var ballYcor: Double = -140.0
    @State private var pause: Bool = false
    @State private var xaxisvelocity: Double = 0.0
    @State private var yaxisacceleration: Double = 20.0
    @State private var ballTimer: Timer?
    private let roomCollection = Firestore.firestore().collection("rooms")
    var joinCode: String
    
    var body: some View {
        ZStack {
            Image("bgwithstick")
                .offset(x:-15.0)
            Image("player1")
                .scaleEffect(0.2)
                .offset(x:player1Xcor,y:110)
            Image("player2")
                .scaleEffect(0.2)
                .offset(x:player2Xcor,y:130)
            Image("ball")
                .scaleEffect(0.1)
                .offset(x:ballXcor,y:ballYcor)
            
            VStack {
                HStack {
                    Text(String(player1Score))
                        .font(.largeTitle)
                    Spacer()
                    if(player1Score >= 11) {
                        Button(action: {
                            player1Score = 0
                            player2Score = 0
                        }) {
                            Text("Player 1 Win !!!!")
                                .font(.title)
                                .padding()
                                .background(Color(hue: 0.969, saturation: 0.949, brightness: 0.994))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }else if(player2Score >= 11){
                        Button(action: {
                            player1Score = 0
                            player2Score = 0
                            restart()
                        }) {
                            Text("Player 2 Win !!!!")
                                .font(.title)
                                .padding()
                                .background(Color(hue: 0.969, saturation: 0.949, brightness: 0.994))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }else {
                        Button(action: {
                            ballMovement()
                            updateBallcor()
                        }) {
                            Text("Start")
                                .font(.title)
                                .padding()
                                .background(Color(hue: 0.322, saturation: 0.75, brightness: 1.0))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    Text(String(player2Score))
                        .font(.largeTitle)
                }
                .frame(width: 750)
                Spacer()
                HStack {
                    Button(action: {
                        moveLeft(player: currentPlayer)
                        updatePlayerXcor(player: currentPlayer)
                    }) {
                        Image(systemName: "arrowshape.left")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .scaleEffect(3.0)
                    }
                    .padding()
                    Spacer()
                    Button(action: {
                        moveRight(player: currentPlayer)
                        updatePlayerXcor(player: currentPlayer)
                    }) {
                        Image(systemName: "arrowshape.right")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .scaleEffect(3.0)
                    }
                    .padding()
                }
                .frame(width: 750)
            }
            .frame(height: 350)
        }
        .onAppear {
            checkChange()
            fetchPlayerNames()
            fetchPlayerXcors()
        }
    }
    
    private func fetchPlayerNames() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        roomCollection.whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching player names:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first {
                self.player1Name = document["createdBy"] as? String ?? ""
                self.player2Name = document["joinBy"] as? String ?? ""
                if(user.uid == player1Name) {
                    currentPlayer = "player1"
                }
                else {
                    currentPlayer = "player2"
                }
            }
        }
    }
    
    private func fetchPlayerXcors() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        roomCollection.whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching player X-coordinates:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first {
                self.player1Xcor = document["player1Xcor"] as? Double ?? -335.0
                self.player2Xcor = document["player2Xcor"] as? Double ?? 335.0
            }
        }
    }
    
    private func updatePlayerXcor(player: String) {
        
        let playerXcorKey = player + "Xcor"
        let newXcor = (player == "player1") ? player1Xcor : player2Xcor
        
        roomCollection.whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error updating player X-coordinate:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first {
                let documentID = document.documentID
                roomCollection.document(documentID).updateData([playerXcorKey: newXcor])
            } else {
                print("No documents found")
            }
        }
    }
    
    private func moveRight(player: String) {
        if(player == "player1"){
            player1Xcor = player1Xcor + 30.71
            if(player1Xcor >= -120.0) {
                player1Xcor = -120.0
            }
            if(player1Xcor <= -335.0){
                player1Xcor = -335.0
            }
        }
        else{
            player2Xcor = player2Xcor + 30.71
            if(player2Xcor <= 120.0) {
                player2Xcor = 120.0
            }
            if(player2Xcor >= 335.0){
                player2Xcor = 335.0
            }
        }
    }
    
    private func moveLeft(player: String) {
        if(player == "player1"){
            player1Xcor = player1Xcor - 30.71
            if(player1Xcor >= -120.0) {
                player1Xcor = -120.0
            }
            if(player1Xcor <= -335.0){
                player1Xcor = -335.0
            }
        }
        else{
            player2Xcor = player2Xcor - 30.71
            if(player2Xcor <= 120.0) {
                player2Xcor = 120.0
            }
            if(player2Xcor >= 335.0){
                player2Xcor = 335.0
            }
        }
    }
    
    private func checkChange(){
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        roomCollection.whereField("joinCode", isEqualTo: joinCode).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to room changes:", error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot found")
                return
            }
            
            let documents = snapshot.documents
            
            if let document = documents.first{
                self.player1Score = document["player1Score"] as? Int ?? 0
                self.player2Score = document["player2Score"] as? Int ?? 0
                self.player1Xcor = document["player1Xcor"] as? Double ?? -335.0
                self.player2Xcor = document["player2Xcor"] as? Double ?? 335.0
                self.ballXcor = document["ballXcor"] as? Double ?? -260.0
                self.ballYcor = document["ballYcor"] as? Double ?? -140.0
            } else {
                print("Room does not exist")
            }
        }
    }
    
    private func ballMovement(){
        let animationDuration: Double = 0.05
        
        // Define animation
        ballTimer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
            withAnimation(Animation.linear(duration: animationDuration)) {
                moveBall()
                updateBallcor()
            }
        }
    }
    
    private func moveBall() {
        ballYcor += yaxisacceleration   //ball dropping
        ballXcor += xaxisvelocity
        
        if ballYcor >= 200 {
            if (ballXcor < 0.0 && ballXcor > -370.0) || ballXcor > 370.0 {
                player2Score += 1
            } else if (ballXcor > 0.0 && ballXcor < 370.0) || ballXcor < -370.0 {
                player1Score += 1
            }
            else {
            }
            updateScore()
            restart()
        } else if ballXcor <= player1Xcor + 100.0 && ballXcor >= player1Xcor - 30.0 && ballYcor >= 80 && ballYcor <= 100{
            xaxisvelocity = Double.random(in: 12.0..<18.0)
            yaxisacceleration = -24.0
        } else if ballXcor <= player2Xcor + 30.0 && ballXcor >= player2Xcor - 100.0 && ballYcor >= 80 && ballYcor <= 100{
            xaxisvelocity = -1 * Double.random(in: 12.0..<18.0)
            yaxisacceleration = -24.0
        } else {
            if(yaxisacceleration <= 8.0 && xaxisvelocity != 0.0){
                yaxisacceleration += 1.9
            }
        }
    }
    
    private func restart(){
        ballTimer?.invalidate() // Stop the timer
        ballTimer = nil
        ballXcor = -240.0
        ballYcor = -140.0
        xaxisvelocity = 0.0
        yaxisacceleration = 20.0
    }
    
    private func updateBallcor() {
        let ballXcorKey = "ballXcor"
        let ballYcorKey = "ballYcor"
        roomCollection.whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error updating player X-coordinate:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first {
                let documentID = document.documentID
                roomCollection.document(documentID).updateData([ballXcorKey: ballXcor])
                roomCollection.document(documentID).updateData([ballYcorKey: ballYcor])
                
            } else {
                print("No documents found")
            }
        }
    }
    private func updateScore() {
        let player1scoreKey = "player1Score"
        let player2scoreKey = "player2Score"
        roomCollection.whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error updating player X-coordinate:", error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first {
                let documentID = document.documentID
                roomCollection.document(documentID).updateData([player1scoreKey: player1Score])
                roomCollection.document(documentID).updateData([player2scoreKey: player2Score])
                
            } else {
                print("No documents found")
            }
        }
    }
}


struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(joinCode: "123")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
