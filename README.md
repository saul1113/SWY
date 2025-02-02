
# 프로젝트 설명

![Image](https://github.com/user-attachments/assets/a9acabeb-dc48-47fe-ad1d-34bc3c30294f)

YouTube Search App은 사용자가 검색어를 입력하면 YouTube의 API를 통해 관련 동영상을 검색하고, 결과를 목록 형태로 표시하는 iOS 애플리케이션입니다.
UIKit 기반으로 개발되었으며, 검색 히스토리 관리와 무한 스크롤 등의 기능을 제공합니다.


# 주요 기능
검색 기능: YouTube Data API를 활용하여 검색어에 따라 동영상 목록을 가져옴.
동영상 목록 표시: 검색 결과를 테이블 뷰로 표시.
동영상 재생: 선택한 동영상의 YouTube 플레이어를 웹뷰에서 로드하여 재생.
검색 히스토리: 검색 히스토리를 저장하여 재활용 가능.

# 추가 기능
- 검색 히스토리 삭제: 검색 히스토리를 개별적으로 삭제하거나, 왼쪽 스와이프로 삭제 가능.
- Diffable DataSource로 TableView 관리
- 이미지캐싱으로 이미지 로딩 관리
- 무한 스크롤 구현: 추가 검색 결과를 무한히 로드 가능.
- API Key 보안: SecretKey.plist 파일을 통해 API Key 관리.
- 반응형 UI: iOS 18.2 이상 환경에서 최적화된 UI 제공.


# 핵심 구조

아키텍쳐
MVC (Model-View-Controller) 패턴을 사용하여 코드의 모듈화를 극대화하였습니다.

## 주요 역할:
- Model: YouTube API 데이터를 처리.
- View: 사용자 인터페이스(UI)를 제공.
- Controller: Model과 View를 연결하고 이벤트를 관리.

# 주요 클래스

## 1. APIData
* YouTube Data API와 통신하여 동영상 및 채널 데이터를 가져오는 역할을 담당.
* 검색어에 따라 동영상 데이터 요청 및 파싱.

## 2. YoutubeViewController
* 검색 바와 테이블 뷰를 통해 검색 및 결과를 표시.
* 검색 히스토리를 관리하며, 검색 결과를 표시하는 로직 포함.

## 3. WebViewController
* 선택한 동영상을 YouTube 플레이어에서 재생하기 위한 웹뷰 컨트롤러.

## 4. YouTubeCell
* 검색 결과를 셀 형태로 표시하며, 썸네일과 채널 이미지 캐싱 기능 포함.


# 앱 흐름

## 검색흐름
- 사용자가 검색어 입력 및 검색 버튼 클릭.
- APIData 클래스에서 YouTube Data API 호출.
- 결과 데이터를 YoutubeSearchModel로 디코딩하여 테이블 뷰에 표시.

## 검색 히스토뢰 관리
* 검색어는 UserDefaults에 저장되며, 최근 검색어를 히스토리로 보여줌.
* 스와이프 동작 또는 히스토리 삭제 버튼으로 개별 삭제 가능.

## 동영상 선택
* 사용자가 테이블 뷰 셀 클릭.
* WebViewController가 호출되어 해당 동영상을 웹뷰에서 재생.

# 클래식 도식화

YoutubeViewController

├── APIData

├── WebViewController

└── YouTubeCell


# 개발 환경
- iOS 버전: 18.2 이상
- Xcode 버전: 15.0 이상
- 언어: Swift 5.9
- 프레임워크: UIKit, Foundation, WebKit


