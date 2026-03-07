//
//  CompleteHabitView.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 15/9/2025.
//

import SwiftUI
import SwiftData
import Foundation
import PhotosUI
import AVFoundation

struct CompleteHabitView: View {
    var habit: Habit
    @ObservedObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: CompleteHabitViewModel
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var photoData : Data? = nil
    @State private var completionImg: UIImage?
    @State private var note: String = ""
    @State private var showCamera : Bool = false
    @State private var showPhotoPicker : Bool = false
    @State private var completionDate: Date?
    @State private var showPhotoOptions = false
    @State private var showCameraPermissionAlert = false  

    init(habit: Habit, homeViewModel: HomeViewModel) {
        self.habit = habit
        self.homeViewModel = homeViewModel
        self._viewModel = StateObject(wrappedValue: CompleteHabitViewModel(homeViewModel: homeViewModel))
    }
    
    var body : some View {
        ScrollView{
            VStack(spacing:24) {
                headerSection
                photoSection
                descriptionSection
                completeButton
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Complete Habit")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                dismiss() 
            }
        } message: {
            Text(viewModel.successMessage ?? "Habit completed!")
        }
        .alert("Camera Access Required", isPresented: $showCameraPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable camera access in Settings to take photos.")
        }
        .confirmationDialog("Photo Options", isPresented: $showPhotoOptions, titleVisibility: .visible) {
            Button("Take Photo") {
                checkCameraPermission()
            }
            Button("Choose from Library") {
                showPhotoPicker = true
            }
            Button("Remove Photo", role: .destructive) {
                completionImg = nil
                photoData = nil
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                completionImg = image
                if let data = image.jpegData(compressionQuality: 0.8) {
                    photoData = data
                }
                showCamera = false
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { x, y in
            if let newItem = y {
                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self) {
                            self.photoData = data
                            self.completionImg = UIImage(data: data)
                        }
                    } catch {
                        viewModel.errorMessage = "Failed to load image."
                        viewModel.showError = true
                    }
                }
            }
        }
    }

    // MARK: - Header Section    
    @ViewBuilder
    var headerSection : some View {
        VStack(alignment: .leading, spacing:8) {
            Text("Completing:")
                .font(.headline)
            Text(habit.name)
                .font(.title).fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Photo Section
    @ViewBuilder
    private var photoSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Add Photo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                if let image = completionImg {
                    VStack(spacing: 12) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                        
                        Button("Change Photo") {
                            showPhotoOptions = true
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(habit.color.color)
                    }
                } else {
                    Button(action: {
                        showPhotoOptions = true
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(habit.color.color)
                            
                            Text("Take Photo or Choose from Library")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(habit.color.color)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(habit.color.color.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(habit.color.color, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Description Section
    @ViewBuilder
    private var descriptionSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Add Description")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("How did it go? (Optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Describe your accomplishment...", text: $note, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16))
                        .lineLimit(3...6)
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Complete Button
    @ViewBuilder
    private var completeButton: some View {
        Button(action: completeHabit) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                }
                
                Text(viewModel.isLoading ? "Completing..." : "Complete Habit")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                completionImg != nil ? Color.green : Color.gray
            )
            .cornerRadius(12)
        }
        .disabled(completionImg == nil || viewModel.isLoading)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Complete Habit Action
    private func completeHabit() {
        Task {
            await viewModel.completeHabit(habit, with: completionImg, note: note)
        }
    }
    
    // MARK: - Camera Permission Check
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showCamera = true
                    } else {
                        self.showCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert = true
        @unknown default:
            showCameraPermissionAlert = true
        }
    }
}

/// Simple Camera View for capturing photos
/// 
/// This uses UIImagePickerController to present the camera interface.
/// 
/// - Parameters: 
///  - onImageCaptured: Closure called with the captured UIImage.
/// 
/// # Methods:
///  - makeUIViewController: Creates and configures the UIImagePickerController.
///  - updateUIViewController: No-op for this implementation.
///  - makeCoordinator: Creates the Coordinator to handle delegate methods.
/// 
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}