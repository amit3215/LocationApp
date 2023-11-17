//
//  PhotoAppApp.swift
//  PhotoApp
//
//  Created by Amit Kumar on 17/9/2023.
//

import SwiftUI

@main
struct PhotoAppApp: App {
    @StateObject var viewModel = LocationViewModel(dataPersister: PlistDataPersister())
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
