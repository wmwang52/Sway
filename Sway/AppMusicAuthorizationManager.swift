//
//  AppMusicAuthorizationManager.swift
//  Sway
//
//  Created by William Wang on 1/29/26.
//

import Foundation
import MusicKit

final class AppMusicAuthorizationManager {
    static let shared = AppMusicAuthorizationManager()
    
    private init(){}
    func checkAndRequestAuthorizationIfNeeded(
           completion: @escaping (MusicAuthorization.Status) -> Void
       ) {
           let status = MusicAuthorization.currentStatus
           
           guard status == .notDetermined else {
               completion(status)
               return
           }
           
           Task {
               let newStatus = await MusicAuthorization.request()
               await MainActor.run {
                   completion(newStatus)
               }
           }
       }
    
    func checkAndRequestAuthorizationIfNeeded() async -> MusicAuthorization.Status {
        let status = MusicAuthorization.currentStatus
        guard status == .notDetermined else { return status }
        return await MusicAuthorization.request()
    }
}


extension AppMusicAuthorizationManager {
    func canPlayCatalogNow() async -> Bool {
        do {
            let subscription = try await MusicSubscription.current
            return subscription.canPlayCatalogContent
        } catch {
            return false
        }
    }
}
