//
//  QuicktypeApp.swift
//  quicktype
//
//  Created by Mike Price on 02.10.2023.
//  Copyright © 2023 quicktype. All rights reserved.
//

import SwiftUI
import WebKit

@main
struct QuicktypeApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) 
	var appDelegate
	
	@AppStorage("hasRunBefore")
	var isFirstRun: Bool = true
	
	@Environment(\.openURL)
	var openURL
	
	var body: some Scene {
		WindowGroup {
			WebView(url: URL(string: "https://app.quicktype.io/#l=swift&context=xcode")!)
				.alert("quicktype's Xcode extension is ready to use", isPresented: $isFirstRun) {
					Button("Ok") {
						isFirstRun = false
					}
					
					Button("Open System Preferences") {
						openURL(URL(string: "x-apple.systempreferences:com.apple.preferences.extensions")!)
						isFirstRun = false
					}
				} message: {
					Text("Enable the extension in System Preferences → Extensions, then find \"Paste JSON as\" in Xcode's Editor menu.")
				}
		}
		.defaultSize(width: 1000, height: 500)
		.commands {
			CommandGroup(replacing: .help) {
				Button("How to enable Xcode extension?") {
					isFirstRun = true
				}
				
				Button("GitHub") {
					openURL(URL(string: "https://github.com/quicktype/quicktype")!)
				}
				
				Button("About") {
					openURL(URL(string: "https://quicktype.io")!)
				}
				
				Button("Help") {
					openURL(URL(string: "https://github.com/quicktype/quicktype-xcode/issues/new")!)
				}
			}
		}
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		true
	}
}

struct WebView: NSViewRepresentable {
	let url: URL
	
	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	func makeNSView(context: Context) -> WKWebView {
		let wkwebView = WKWebView()
		wkwebView.navigationDelegate = context.coordinator
		wkwebView.uiDelegate = context.coordinator
		wkwebView.load(URLRequest(url: url))
		return wkwebView
	}
	
	func updateNSView(_ nsView: WKWebView, context: Context) {
	}
	
	final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
		func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
			guard 
				let url = navigationAction.request.url,
				isExternal(url)
			else {
				return .allow
			}
			
			openExternalLink(navigationAction)
			
			return .cancel
		}
		
		func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
			if navigationAction.targetFrame == nil {
				openExternalLink(navigationAction)
			}
			
			return nil
		}
		
		private func isExternal(_ url: URL) -> Bool {
			let s = url.absoluteString
			return s.starts(with: "http") && !s.starts(with: "https://app.quicktype.io")
		}
		
		private func openExternalLink(_ navigationAction: WKNavigationAction) {
			guard let url = navigationAction.request.url else { return }
			NSWorkspace.shared.open(url)
		}
	}
}
