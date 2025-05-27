//
//  Test_EffectiveMobileApp.swift
//  Test-EffectiveMobile
//
//  Created by Nurkhat on 24.05.2025.
//

import SwiftUI

@main
struct Test_EffectiveMobileApp: App {
    var body: some Scene {
        WindowGroup {
            ToDoListView(controller: ToDoListViewController())
        }
    }
}
