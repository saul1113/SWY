//
//  WebViewController.swift
//  YoutubeUikit
//
//  Created by 강희창 on 1/21/25.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var videoID: String?
    private let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        loadVideo()
    }
    
    private func setUpUI() {
        view.backgroundColor = .systemBackground
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadVideo() {
        guard let videoID = videoID else { return }
        let urlString = "https://www.youtube.com/embed/\(videoID)"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
