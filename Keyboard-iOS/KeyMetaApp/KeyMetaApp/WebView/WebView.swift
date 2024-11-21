//  WebView.swift
//  KeyMetaApp
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import SwiftUI
import WebKit


struct WebView: View {
    
    @State private var isLoading: Bool = true
    
    let url: URL
    
    var body: some View {
        ZStack {
            WebViewWrapper(url: url, isLoading: $isLoading)
            if isLoading {
                ProgressView("Loading...")
            }
        }
    }
}

fileprivate class WebViewModel: ObservableObject {
    let url: URL
    let isLoading: Binding<Bool>
    
    init(url: URL, isLoading: Binding<Bool>) {
        self.url = url
        self.isLoading = isLoading
    }
}

fileprivate struct WebViewWrapper: UIViewRepresentable {
    private let viewModel: WebViewModel
    private let webView = WKWebView()
    
    init(url: URL, isLoading: Binding<Bool>) {
        self.viewModel = WebViewModel(url: url, isLoading: isLoading)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: self.viewModel)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private let viewModel: WebViewModel
        
        fileprivate init(viewModel: WebViewModel) {
            self.viewModel = viewModel
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            self.viewModel.isLoading.wrappedValue = false
        }
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<WebViewWrapper>) { }
    
    func makeUIView(context: Context) -> UIView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.load(URLRequest(url: viewModel.url))
        return self.webView
    }
}
