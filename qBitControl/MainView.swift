//
//  MainView.swift
//  TorrentAttempt
//
//  Created by Michał Grzegoszczyk on 26/10/2022.
//

import SwiftUI

struct MainView: View {
    
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        if(!isLoggedIn) {
            ServersView(isLoggedIn: $isLoggedIn)
        } else {
            VStack {
                LoggedInView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
