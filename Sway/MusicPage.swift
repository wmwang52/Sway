//
//  MusicPage.swift
//  Sway
//
//  Created by William Wang on 1/29/26.
//

import SwiftUI
import MusicKit

struct MusicPage: View {
    @State private var query = "Mac Miller"
    @State private var albums: [Album] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search albums", text: $query)
                        .textFieldStyle(.roundedBorder)
                    Button("Search") {
                        Task { await searchAlbums() }
                    }
                    .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding()

                if isLoading {
                    ProgressView("Searching…")
                        .padding()
                } else if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    List(albums, id: \.id) { album in
                        AlbumRow(album: album)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search Albums")
        }
        .task {
            // Optionally run an initial search
            await searchAlbums()
        }
    }

    private func searchAlbums() async {
        // Check current authorization synchronously
        var status = MusicAuthorization.currentStatus

        // If not authorized, request it asynchronously
        if status != .authorized {
            status = await MusicAuthorization.request()
        }

        guard status == .authorized else {
            await MainActor.run {
                self.errorMessage = "Music access not authorized."
            }
            return
        }

        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            var request = MusicCatalogSearchRequest(term: query, types: [Album.self])
            request.limit = 25
            let response = try await request.response()
            let foundAlbums = response.albums
            await MainActor.run {
                self.albums = Array(foundAlbums)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

struct AlbumRow: View {
    let album: Album

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: album.artwork?.url(width: 100, height: 100)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(.secondary.opacity(0.2))
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
#Preview {
    MusicPage()
}
