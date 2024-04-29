//
//  SettingsView.swift
//  Vapp
//
//  Created by Abdulhakim Ajetunmobi on 27/03/2024.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                  ProgressView()
                } else {
                    PhotosPicker(selection: $selectedPhoto) {
                        ZStack {
                            if let url = viewModel.imageURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 200)
                                            .clipShape(Circle())
                                    case .failure:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                            .clipShape(Circle())
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                            }
                        }
                    }.padding(16)
                    
                    VStack {
                        Text("Username: \(homeViewModel.user?.name ?? "")")
                        Text("Display Name: \(homeViewModel.user?.displayName ?? "")")
                    }.padding(16)
                    
                    Button("Logout") {
                        Task {
                            await homeViewModel.logout()
                            dismiss()
                        }
                    }
                    .tint(.red)
                    .buttonStyle(.bordered)
                }
            }
            .onAppear {
                viewModel.updateURL(urlString: homeViewModel.user?.imageURL)
            }
            .task(id: selectedPhoto) {
                if let selectedPhoto {
                    viewModel.isLoading = true
                    await viewModel.updateUserImage(selectedPhoto, authToken: homeViewModel.token)
                    homeViewModel.updateUser(imageURL: viewModel.imageURL?.absoluteString)
                    viewModel.isLoading = false
                }
            }
            .alert(isPresented: $viewModel.errorContainer.hasError) {
                Alert(title: Text("Error Making Call"), message: Text(viewModel.errorContainer.text))
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

final class SettingsViewModel: ObservableObject {
    @Published var imageURL: URL?
    @Published var isLoading = false
    @Published var errorContainer = (hasError: false, text: "")
    
    @MainActor
    func updateURL(urlString: String?) {
        if let urlString {
            imageURL = URL(string: urlString)
        }
    }
    
    @MainActor
    func updateUserImage(_ selectedItem: PhotosPickerItem, authToken: String?) async {
        do {
            guard let authToken else {
                errorContainer = (true, "Auth Token Missing")
                return
            }
            
            guard let imageData = try await selectedItem.loadTransferable(type: Data.self),
                  let mimeType = selectedItem.supportedContentTypes.first?.preferredMIMEType else {
                      errorContainer = (true, "Error Loading Image")
                      return
                  }
            
            let uploadResponse: ImageUpload.Response = try await RemoteLoader.multipart(path: ImageUpload.profilePath, mimeType: mimeType, authToken: authToken, data: imageData)
            updateURL(urlString: uploadResponse.imageURL)
            
        } catch  {
            errorContainer = (true, error.localizedDescription)
        }
    }
}
