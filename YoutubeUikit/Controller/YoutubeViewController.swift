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
    private let historyTableView = UITableView()
    
    private let api = APIData()
    private let searchHistoryKey = "SearchHistoryKey"
    private var videos: [(video: YoutubeSearchModel.Video, channelImageURL: String?)] = []
    private var searchHistory: [String] = []
    private var nextPage: String?
    private var loading = false
    
    private var historyTableViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadSearchHistory()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupTableView()
        setupHistoryTableView()
        setupNavigationBar()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(YouTubeCell.self, forCellReuseIdentifier: "VideoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupHistoryTableView() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.isHidden = true
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(historyTableView)
        
        NSLayoutConstraint.activate([
            historyTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            historyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            historyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        //히스토리 높이를 동적으로 변경
        historyTableViewHeightConstraint = historyTableView.heightAnchor.constraint(equalToConstant: 0)
        historyTableViewHeightConstraint?.isActive = true
    }
    
    private func setupNavigationBar() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    // MARK: - 검색 히스토리 메서드
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: searchHistoryKey) ?? []
    }
    
    private func saveSearchHistory(keyword: String) {
        // 중복된 검색어는 제거
        if let existingIndex = searchHistory.firstIndex(of: keyword) {
            searchHistory.remove(at: existingIndex)
        }
        // 최신 검색어를 맨 앞에 추가
        searchHistory.insert(keyword, at: 0)
        // 검색 기록의 최대 개수를 제한
        if searchHistory.count > 5 {
            searchHistory.removeLast()
        }
        // UserDefaults에 저장
        UserDefaults.standard.set(searchHistory, forKey: searchHistoryKey)
    }
    
    private func updateHistoryTableViewHeight() {
        let rowHeight: CGFloat = 44
        let maxVisibleRows = 5
        let height = min(CGFloat(searchHistory.count) * rowHeight, CGFloat(maxVisibleRows) * rowHeight)
        // 히스토리 테이블뷰가 표시 중일 때만 높이 업데이트
        historyTableViewHeightConstraint?.constant = historyTableView.isHidden ? 0 : height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - API Fetch
    private func fetchVideos(keyword: String) {
        guard !loading else { return }
        loading = true
        
        api.fetchVideoData(keyword: keyword, pageToken: nextPage) { [weak self] result in
            guard let self = self else { return }
            self.loading = false
            
            switch result {
            case .success(let response):
                self.nextPage = response.nextPageToken
                let fetchedVideos = response.items.map { video in
                    (video: video, channelImageURL: String?.none)
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
                        print("Error fetching channel images: \(error)")
                    }
                }
            case .failure(let error):
                print("Error fetching videos: \(error)")
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension YoutubeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        historyTableView.isHidden = false
        historyTableView.reloadData()
        updateHistoryTableViewHeight()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        saveSearchHistory(keyword: keyword)
        videos = []
        nextPage = nil
        tableView.reloadData()
        fetchVideos(keyword: keyword)
        historyTableView.isHidden = true
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension YoutubeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == historyTableView ? searchHistory.count : videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == historyTableView {
            let cell = UITableViewCell()
            cell.textLabel?.text = searchHistory[indexPath.row] //최신 검색어부터 순서대로
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! YouTubeCell
            let (video, channelImageURL) = videos[indexPath.row]
            cell.configure(with: video, channelImageURL: channelImageURL)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == historyTableView {
            let selectedKeyword = searchHistory[indexPath.row]
            searchBar.text = selectedKeyword
            searchBarSearchButtonClicked(searchBar)
        } else {
            let video = videos[indexPath.row].video
            let webVC = WebViewController()
            webVC.videoID = video.id.videoId
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

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
