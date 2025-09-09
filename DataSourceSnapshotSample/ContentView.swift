//
//  ContentView.swift
//  DataSourceSnapshotSample
//
//  Created by 樋川大聖 on 2025/09/09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("UICollectionView DiffableDataSource Sample")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("NSDiffableDataSourceSnapshotの挙動を確認できます")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                CollectionViewWrapperRepresentable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("DataSource Sample")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
