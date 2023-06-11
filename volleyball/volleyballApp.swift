//
//  volleyballApp.swift
//  volleyball
//
//  Created by 李炘杰 on 2023/6/9.
//

import SwiftUI
import Firebase

@main
struct volleyballApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
