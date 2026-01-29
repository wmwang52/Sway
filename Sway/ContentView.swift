//
//  ContentView.swift
//  Sway
//
//  Created by William Wang on 1/29/26.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @State private var authStatus: MusicAuthorization.Status = MusicAuthorization.currentStatus
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 16) {
            if authStatus == .authorized {
                MusicPage()
            } else {
                Button {
                    Task { await requestAuthorization() }
                } label: {
                    if isRequesting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Enable Apple Music Access")
                    }
                }
                .disabled(isRequesting)

                if authStatus == .denied || authStatus == .restricted {
                    VStack(spacing: 8) {
                        Text("Access is \(statusDescription(authStatus)).")
                        Button("Open Settings") {
                            openAppSettings()
                        }
                    }
                }
            }
        }
        .task { await refreshStatus() }
    }

    private func refreshStatus() async {
        let status = MusicAuthorization.currentStatus
        await MainActor.run { authStatus = status }
    }

    private func requestAuthorization() async {
        await MainActor.run { isRequesting = true }
        let status = await AppMusicAuthorizationManager.shared.checkAndRequestAuthorizationIfNeeded()
        await MainActor.run {
            authStatus = status
            isRequesting = false
        }
    }

    private func statusDescription(_ status: MusicAuthorization.Status) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ContentView()
}
