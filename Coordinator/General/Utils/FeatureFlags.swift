//
//  FeatureFlags.swift
//  Coordinator
//
//  Created by Friss, Shay (206845153) on 11/4/25.
//

// https://swiftwithmajid.com/2025/09/16/feature-flags-in-swift/
import Foundation

public enum Distribution: Sendable {
    case debug
    case appstore
    case testflight
}

extension Distribution {
    static var current: Self {
        #if APPSTORE
        return .appstore
        #elseif TESTFLIGHT
        return .testflight
        #else
        return .debug
        #endif
    }
}

public struct FeatureFlags: Sendable, Decodable {
    public let requirePaywall: Bool
    public let requireOnboarding: Bool
    public let featureX: Bool

    public init(distribution: Distribution) {
        switch distribution {
        case .debug:
            self.requirePaywall = true
            self.requireOnboarding = true
            self.featureX = true
        case .appstore:
            self.requirePaywall = true
            self.requireOnboarding = true
            self.featureX = false
        case .testflight:
            self.requirePaywall = false
            self.requireOnboarding = true
            self.featureX = true
        }
    }
}


/** USAGE
 
 @main
 struct CardioBotApp: App {
     var body: some Scene {
         WindowGroup {
             RootView()
                 .environment(\.featureFlags, FeatureFlags(distribution: .current))
         }
     }
 }

 
 */
