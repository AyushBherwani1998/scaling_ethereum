//
//  frontendApp.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    UIApplication.shared.delegate?.window??.overrideUserInterfaceStyle = .dark
    return true
  }
}

@main
struct frontendApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
       
        WindowGroup {
            
            ContentView(viewModel: MainViewModel())
        }
    }
}
