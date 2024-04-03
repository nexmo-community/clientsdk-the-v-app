//
//  SettingsView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 27/03/2024.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Logout") {
                    Task {
                        await viewModel.logout()
                        dismiss()
                    }
                }
                .tint(.red)
                .buttonStyle(.bordered)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
