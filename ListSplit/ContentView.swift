//
//  ContentView.swift
//  ListSplit
//
//  Created by stud on 29/10/2024.
//

import SwiftUI


struct ContentView: View {
    @State var loggedIn = false
    @StateObject var loggedInUser = LoggedUser()
    
    
    var body: some View {
        if loggedIn {
            ListsView()
                .environmentObject(loggedInUser)
        }
        else {
            LoginView(loggedIn: $loggedIn)
                .environmentObject(loggedInUser)
        }
            

    }
}
#Preview {
    ContentView()
}
