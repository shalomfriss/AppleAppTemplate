//
//  ContentView.swift
//  Coordinator
//
//  Created by Shalom Friss on 3/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        ZStack {
            // Main content always visible
            HomeView()
                .environmentObject(coordinator)

            // Overlay a routed view when the coordinator has a presented route
            if let route = coordinator.presented {
                routedView(for: route)
                    .environmentObject(coordinator)
                    // simple background to float above the main view
                    .background(.ultraThinMaterial)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(), value: coordinator.presented)
    }
}

private struct HomeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome")
                .font(.largeTitle)
            Button("Show detail") {
                coordinator.showDetail(message: "Coordinated navigation works!")
            }
        }
        .padding()
        .navigationTitle("Home")
    }
}

private struct DetailView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.title3)
            Button("Close") {
                coordinator.pop()
            }
            Button("Pop to root") {
                coordinator.popToRoot()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: 600)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(radius: 20)
        .padding()
    }
}

// Helper to convert a Route into a concrete View
private extension ContentView {
    @ViewBuilder
    func routedView(for route: AppCoordinator.Route) -> some View {
        switch route {
        case .detail(let message):
            DetailView(message: message)
        }
    }
}

#Preview {
    ContentView()
}
