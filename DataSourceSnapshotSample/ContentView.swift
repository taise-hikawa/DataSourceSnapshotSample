//
//  ContentView.swift
//  DataSourceSnapshotSample
//
//  Created by 樋川大聖 on 2025/09/09.
//

import SwiftUI

enum DataSourceVersion: Int, CaseIterable {
    case v1 = 0
    case v2 = 1
    case v3 = 2
    case v4 = 3
    
    var title: String {
        switch self {
        case .v1: return "V1 (通常)"
        case .v2: return "V2 (items付き)"
        case .v3: return "V3 (Hash除外)"
        case .v4: return "V4 (両方除外)"
        }
    }
}

struct ContentView: View {
    @State private var selectedVersion = DataSourceVersion.v1
    
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
                    ForEach(DataSourceVersion.allCases, id: \.self) { version in
                        Text(version.title).tag(version)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                switch selectedVersion {
                case .v1:
                    CollectionViewWrapperRepresentable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .v2:
                    CollectionViewWrapperV2Representable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .v3:
                    CollectionViewWrapperV3Representable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .v4:
                    CollectionViewWrapperV4Representable()
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
