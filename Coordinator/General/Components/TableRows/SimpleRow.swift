//
//  SimpleRow.swift
//  Coordinator
//
//  Created by Friss, Shay (206845153) on 10/23/25.
//

import Foundation
import SwiftUI

/// A simple row with a title and description
struct SimpeRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
        }
    }
}

