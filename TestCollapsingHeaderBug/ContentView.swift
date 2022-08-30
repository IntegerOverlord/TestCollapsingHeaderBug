//
//  ContentView.swift
//  TestCollapsingHeaderBug
//
//  Created by Maksym Fedoriaka on 30.08.2022.
//

import SwiftUI

class Coordinator: UINavigationController {
    lazy var viewModel = TestViewModel(coordinator: self)

    init() {
        super.init(nibName: nil, bundle: nil)
        self.setViewControllers([UIHostingController(rootView: ContentView(coordinator: self))], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showScrollView() {
        let vc = UIHostingController(rootView: ScrollViewDemo(viewModel: self.viewModel))
        vc.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
               title: "Continue",
               style: .plain,
               target: self,
               action: #selector(showModal)
           )
        ]
        self.pushViewController(vc, animated: true)
    }

    func showList() {
        let vc = UIHostingController(rootView: ListDemo(viewModel: self.viewModel))
        vc.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
               title: "Continue",
               style: .plain,
               target: self,
               action: #selector(showModal)
           )
        ]
        self.pushViewController(vc, animated: true)
    }

    @objc
    func showModal() {
        self.present(UIHostingController(rootView: ModalView(viewModel: self.viewModel)), animated: true)
    }
}

struct ContentView: View {
    weak var coordinator: Coordinator?

    var body: some View {
        VStack {
            Button("Scroll View") {
                self.coordinator?.showScrollView()
            }
            Button("List View") {
                self.coordinator?.showList()
            }
        }
    }
}

struct HeaderView: View {
    let text: String
    let backgroundColor: Color

    var body: some View {
        Text(self.text)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(self.backgroundColor)
    }
}

struct ScrollViewDemo: View {
    @ObservedObject var viewModel: TestViewModel

    var body: some View {
        ScrollViewWithCollapsingHeader(
            header: HeaderView(text: "Scroll View Demo", backgroundColor: .green),
            headerBackgroundColor: .green
        ) {
            LazyVStack(spacing: 0) {
                ForEach(self.viewModel.items) {
                    Text("\($0)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                }
            }
        }
    }
}

struct ListDemo: View {
    @ObservedObject var viewModel: TestViewModel

    var body: some View {
        ListWithCollapsingHeader(
            header: HeaderView(text: "List View Demo", backgroundColor: .yellow),
            headerBackgroundColor: .yellow,
            style: .grouped
        ) {
            Section(header: EmptyHeaderFooterView()) {
                ForEach(self.viewModel.items) {
                    Text("\($0)")
                }
            }
        }
    }
}

class TestViewModel: ObservableObject {
    @Published var items: [Int] = Array(1..<5000)
    weak var coordinator: Coordinator?

    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
}

extension Int: Identifiable {
    public var id: String {
        "\(self)"
    }
}

struct ModalView: View {
    let viewModel: TestViewModel

    var body: some View {
        Button("Do stuff") {
            self.viewModel.items = Array(1..<100).suffix(Int.random(in: 50..<100))
        }
    }
}
