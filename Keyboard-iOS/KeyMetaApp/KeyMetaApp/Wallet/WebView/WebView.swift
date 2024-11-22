import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var webView: WKWebView
    @ObservedObject var webViewStore: WebViewStore
    @EnvironmentObject var viewStateManager: ViewStateManager
    private let messageProcessor: TonLogicMessageProcessor
    
    init(webViewStore: WebViewStore) {
        
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
                
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        
        self.messageProcessor = DefaultTonLogicMessageProcessor(viewStateManager: ViewStateManager())
        userContentController.add(WebViewMessageHandler(messageProcessor: self.messageProcessor), name: "nativeApp")
        
        self.webViewStore = webViewStore
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // Create new message processor with the actual ViewStateManager
        let processor = DefaultTonLogicMessageProcessor(viewStateManager: viewStateManager)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "nativeApp")
        webView.configuration.userContentController.add(WebViewMessageHandler(messageProcessor: processor), name: "nativeApp")
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        loadWebContent(webView)
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        
        self.webViewStore.webView = self
        
        return coordinator
    }
    
    private func loadWebContent(_ webView: WKWebView) {
        let address = "http://192.168.1.67:3000"
        //let address = "https://d4rh1z6vnsnbq.cloudfront.net"
        if let url = URL(string: address) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
            var parent: WebView
            
            init(_ parent: WebView) {
                self.parent = parent
            }
            
            // Handle navigation actions
            func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                // Allow normal navigation
                decisionHandler(.allow)
            }
            
            // Handle new window requests (for _blank targets)
            func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
                if navigationAction.targetFrame == nil {
                    if let url = navigationAction.request.url {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                return nil
            }
        }
    
    // Send message to JavaScript
    func sendMessageToWeb(type: String, payload: String) {
        let javascriptCode = "window.receiveMessageFromNative('\(type)', '\(payload)')"
        webView.evaluateJavaScript(javascriptCode) { (result, error) in
            if let error = error {
                print("Error sending message to web: \(error)")
            }
        }
    }
}

struct WebMessageModel: Codable {
    let type: String
    let success: Bool
    let message: String
}

// Message handler for receiving messages from JavaScript
class WebViewMessageHandler: NSObject, WKScriptMessageHandler {
    private let messageProcessor: TonLogicMessageProcessor
    
    init(messageProcessor: TonLogicMessageProcessor) {
        self.messageProcessor = messageProcessor
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let jsonData = (message.body as? String)?.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    let decodedObject = try decoder.decode(WebMessageModel.self, from: jsonData)

                    self.messageProcessor.processMessage(decodedObject)
                } catch {
                    print("Decoding error: \(error)")
                }
            }
    }
}

