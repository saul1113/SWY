//
//  YoutubeViewController.swift
//  YoutubeUikit
//
//  Created by 강희창 on 1/21/25.
//

import UIKit

class YoutubeViewController: UIViewController {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let api = APIData()
    
    private var videos: [(video: YoutubeSearchModel.Video, channelImageURL: String?)] = []
    private var nextPage: String?
    private var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        view.backgroundColor = .systemBackground
        
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(YouTubeCell.self, forCellReuseIdentifier: "VideoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchVideos(keyword: String) {
        guard !loading else { return }
        loading = true
        
        api.fetchVideoData(keyword: keyword, pageToken: nextPage) { [weak self] result in
            guard let self else { return }
            self.loading = false
            
            switch result {
            case .success(let response):
                self.nextPage = response.nextPageToken
                let fetchedVideos = response.items.map { video in
                    (video: video, channelImageURL: String?.none) // 초기값은 nil
                }
                
                let channelIDs = response.items.map { $0.snippet.channelId }
                self.api.fetchChannelImages(channelIDs: channelIDs) { channelResult in
                    switch channelResult {
                    case .success(let channelImages):
                        let updatedVideos = fetchedVideos.map { (video, _) in
                            (video: video, channelImageURL: channelImages[video.snippet.channelId])
                        }
                        self.videos.append(contentsOf: updatedVideos)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print("Error fetching channel images:", error)
                    }
                }
            case .failure(let error):
                print("Error fetching videos:", error)
            }
        }
    }
}

// MARK: - 테이블뷰 및 서치바 Extension
extension YoutubeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! YouTubeCell
        let (video, channelImageURL) = videos[indexPath.row]
        cell.configure(with: video, channelImageURL: channelImageURL)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = videos[indexPath.row].video
        let webVC = WebViewController()
        webVC.videoID = video.id.videoId
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension YoutubeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        videos = []     //video 리셋
        nextPage = nil
        tableView.reloadData()
        fetchVideos(keyword: keyword)
    }
}

extension YoutubeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y    //스크롤 수직방향 위치
        let contentHeight = scrollView.contentSize.height   //스크롤뷰의 전체 콘텐츠 높이
        let height = scrollView.frame.size.height   //스크롤뷰의 표시되는 화면의 영역 높이
        
        //스크롤 콘텐츠 끝부분 100pt 이내에 도달했는지, 스크롤 가능한 가장 아래위치
        if offsetY > contentHeight - height - 100 && !loading && nextPage != nil {  //로딩중이면 추가요청 방지, 다음 페이지토큰이 있는지 확인
            fetchVideos(keyword: searchBar.text ?? "")  //키워드를 통해 추가 동영상 데이터를 가져오는
            
            /*
             •    - 100의 역할:
             •    데이터를 미리 로드하여 스크롤이 완료될 때까지 사용자에게 부드러운 경험을 제공합니다.
             •    만약 - 100 대신 0을 사용하면, 스크롤이 완전히 끝났을 때만 데이터를 로드합니다. 이는 사용자 경험에 영향을 줄 수 있습니다.
             •    loading 플래그:
             •    API 호출이 끝나기 전에 또 다른 요청을 보내는 것을 방지합니다.
             •    loading은 API 요청이 완료되면 다시 false로 설정됩니다.
             •    nextPage:
             •    YouTube API에서 반환되는 nextPageToken을 통해 페이지네이션을 구현합니다.
             •    nextPage가 nil이면 더 이상 추가 데이터를 요청하지 않습니다.
             */
        }
    }
}
