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
        view.backgroundColor = .black
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
        let html = """
        <html>
        <head>
        <style>
        body {
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh; /* 화면 전체 높이 */
            background-color: black;
        }
        .video-container {
            position: relative;
            width: 100%;
            max-width: 90%; /* 좌우 여백을 주어 화면에 잘 맞추기 위해 사용 */
            height: 56.25vw; /* 16:9 비율 유지 */
            max-height: 100%; /* 높이를 화면 안에서 제한 */
        }
        .video-container iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }
        </style>
        </head>
        <body>
        <div class="video-container">
            <iframe src="https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&showinfo=0"
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen>
            </iframe>
        </div>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
