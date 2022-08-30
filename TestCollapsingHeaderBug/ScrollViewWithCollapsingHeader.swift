//
//  ScrollViewWithCollapsingHeader.swift
//  ListWithCollapsingHeaderDemo
//
//  Created by Maksym Fedoriaka on 15.08.2022.
//

import Foundation
import SwiftUI

struct ScrollViewWithCollapsingHeader<Content: View, HeaderView: View>: View {
    private let coordinateSpaceName = "StickyHeaderCoordinateSpaceName"
    @State private var headerSize: CGSize = .zero
    @State private var scrollOffset: CGFloat = 0

    private let header: HeaderView
    private let content: Content
    private let headerBackgroundColor: Color

    init(
        header: HeaderView,
        headerBackgroundColor: Color,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.headerBackgroundColor = headerBackgroundColor
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named(self.coordinateSpaceName)).origin
                        )
                }
                .frame(height: self.headerSize.height)

                self.content
            }
        }
        .coordinateSpace(name: self.coordinateSpaceName)
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: self.handleOffsetChange)
    }

    func handleOffsetChange(to offset: CGPoint) {
        self.scrollOffset = offset.y
    }
}
