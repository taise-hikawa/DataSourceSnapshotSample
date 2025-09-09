//
//  ContentView.swift
//  DataSourceSnapshotSample
//
//  Created by 樋川大聖 on 2025/09/09.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedVersion = 0
    
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
                
                Picker("バージョン", selection: $selectedVersion) {
                    Text("V1 (通常)").tag(0)
                    Text("V2 (items付き)").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedVersion == 0 {
                    CollectionViewWrapperRepresentable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    CollectionViewWrapperV2Representable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("DataSource Sample")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
