//
//  AccountInfoRow.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import SwiftUI

struct AccountInfoRow: View {
    let email: String?
    var body: some View {
        HStack {
            let initial = String((email?.first ?? "?")).uppercased()
            ZStack {
                Circle()
                    .foregroundStyle(.accent)
                Text(initial)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)
            .mask(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(email?.isEmpty == true ? "Not set" : email ?? "Not set")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("View account information")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    AccountInfoRow(email: nil)
}
