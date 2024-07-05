//
//  View+Extension.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 5/7/2024.
//

import Foundation
import SwiftUI

// MARK: Extensions
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func getSizeOfView(_ getSize: @escaping ((CGSize) -> Void)) -> some View {
        return self
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { value in
                        getSize(value)
                    }
                }
            }
    }
}

