//
//  GalleryView.swift
//  SnapHabit-v2
//
//  Created by Agam Singh on 16/9/2025.
//

import SwiftUI

struct GalleryView: View {
    // MARK: - State Properties
    @ObservedObject private var themeManager = ThemeManager.sharedTheme
    @EnvironmentObject var homeViewModel: HomeViewModel
    @StateObject private var galleryViewModel: GalleryViewModel

    init() {
        self._galleryViewModel = StateObject(wrappedValue: GalleryViewModel(homeViewModel: HomeViewModel()))
    }

    // MARK: - Main View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    headerSection

                    // MARK: - Search Section
                    searchBar

                    // MARK: - Category Filter Section
                    categoryFilterSection

                    // MARK: - Albums List
                    albumsSection
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .environment(\.colorScheme, themeManager.colorScheme ?? .light)
        .onAppear {
            galleryViewModel.homeViewModel = homeViewModel
            galleryViewModel.loadHabitAlbums()
        }
        .refreshable {
            galleryViewModel.loadHabitAlbums()
        }
    }

    // MARK: - Header Section
    @ViewBuilder
    private var headerSection: some View {
        Text("Gallery")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .padding(.top, 20)
            .padding(.horizontal, 20)
    }


    //  MARK: - Search Bar
    @ViewBuilder
    private var searchBar: some View {
        TextField("Search Habits", text: $galleryViewModel.searchText)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
    }

    // MARK: - Header Section
    @ViewBuilder
    private var categoryFilterSection: some View {
        VStack(spacing: 12) {
            Text("Filter by Category")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Picker("Category", selection: $galleryViewModel.selectedCategory) {
                Text("All").tag("All")
                ForEach(galleryViewModel.categoryList(), id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: galleryViewModel.selectedCategory) { newCategory in
                galleryViewModel.filterByCategory(category: newCategory)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)

    }
    }

    // MARK: - Albums Section
    @ViewBuilder
    private var albumsSection: some View {
        if galleryViewModel.isLoading {
            loadingView
        } else if galleryViewModel.filteredHabitAlbums.isEmpty  {
            emptyStateView
        } else {
            albumsListView
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading albums...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("No Photo Albums")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Complete habits with photos to create albums!")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var albumsListView: some View {
        LazyVStack(spacing: 16) {
            ForEach(galleryViewModel.filteredHabitAlbums) { habit in
                NavigationLink(destination: HabitPhotosView(habit: habit)) {
                    HabitAlbumRowContent(habit: habit)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

// MARK: - Habit Album Row Content
struct HabitAlbumRowContent: View {
    let habit: Habit
    
    private var photoCount: Int {
        return habit.photos.count  
    }
    
    private var coverImage: UIImage? {
        return habit.photos.first?.image
    }
    
    private var formattedDate: String {
        guard let latestPhoto = habit.latestPhoto else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: latestPhoto.timestamp)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Album cover image
            ZStack {
                if let coverImage = coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(habit.color.color, lineWidth: 3)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(habit.color.color.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(habit.color.color)
                        )
                }
                
                // Photo count indicator
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(photoCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .padding(4)
                    }
                }
            }
            
            // Album details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(habit.color.color)
                        .frame(width: 12, height: 12)
                    
                    Text(habit.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                // Category
                Text(habit.category.rawValue)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                // Stats row
                HStack(spacing: 16) {
                    // Current streak
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("\(habit.streakCounter)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    
                    // Total photos
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("\(photoCount) photo\(photoCount == 1 ? "" : "s")")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Last completion date
                Text("Last: \(formattedDate)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    GalleryView()
        .environmentObject(HomeViewModel())
}