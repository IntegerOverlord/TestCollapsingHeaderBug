//
//  ListWithCollapsingHeader.swift
//  ListWithCollapsingHeaderDemo
//
//  Created by Maksym Fedoriaka on 15.08.2022.
//

import Foundation
import SwiftUI

enum SUIStripeViewListStyle {
    case insetGrouped
    case grouped
    case plain
}

struct EmptyHeaderFooterView: View {
    var body: some View {
        Color.clear
            .frame(height: .leastNonzeroMagnitude)
            .listRowInsets(EdgeInsets())
    }
}

struct ListWithCollapsingHeader<Content: View, HeaderView: View>: View {
    @State private var headerSize: CGSize = .zero
    @State private var scrollOffset: CGFloat = 0

    private let header: HeaderView
    private let content: Content
    private let headerBackgroundColor: Color
    private let style: SUIStripeViewListStyle

    init(
        header: HeaderView,
        headerBackgroundColor: Color,
        style: SUIStripeViewListStyle,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.headerBackgroundColor = headerBackgroundColor
        self.style = style
        self.content = content()
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                self.headerBackgroundColor
                    .ignoresSafeArea()
                    .frame(
                        height: max(0, self.headerSize.height + self.scrollOffset)
                    )
                Spacer()
            }

            self.contentView

            VStack {
                self.header
                    .readSize(andUpdate: self.$headerSize)
                    .offset(x: 0, y: self.scrollOffset)

                Spacer()
            }
        }
    }

    @ViewBuilder
    var contentView: some View {
        GeometryReader { proxy in
            List {
                SwiftUI.Section(
                    header: Color.clear
                        .frame(height: self.headerSize.height)
                        .listRowInsets(EdgeInsets())
                        .anchorPreference(key: ScrollOffsetPreferenceKey.self, value: .bounds) {
                            proxy[$0].origin
                        }
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: self.handleOffsetChange),
                    footer: self.blankFooterView
                ) {}

                self.content
            }
            .environment(\.defaultMinListHeaderHeight, .leastNonzeroMagnitude)
            // I'm sorry this is ugly, I haven't found other way to fight the generics with ListStyle
            // Will be fixed with Swift 5.7
            .if(self.style == .insetGrouped) {
                $0.listStyle(.insetGrouped)
            }
            .if(self.style == .grouped) {
                $0.listStyle(.grouped)
            }
            .if(self.style == .plain) {
                $0.listStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var blankFooterView: some View {
        // Requred to not introduce any additional padding due to technical sections SUIStripeView adds
        if self.style == .plain {
            EmptyView()
        } else {
            EmptyHeaderFooterView()
        }
    }

    func handleOffsetChange(to offset: CGPoint) {
        // In .list(.plain) mode towards the end of the scroll, a huge number is put into offset, causing layout bugs
        // To combat this, this limiter is introduced
        // Negative offset (regular scrolling) and other styles are unaffected
        print("\(offset.y)")
        guard offset.y < 0 || abs(self.scrollOffset - offset.y) < UIScreen.main.bounds.height else { return }

        self.scrollOffset = offset.y
    }
}
