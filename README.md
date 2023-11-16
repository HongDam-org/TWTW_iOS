![Group 36334](https://github.com/HongDam-org/TWTW/assets/89020004/4ce8b3d0-711f-4b95-ae4d-c494b0c173a4)

## 길치들을 위한 경로 제공 및 만남 관리 서비스 앱

- 길치들을 위한 목적지 경로 제공으로 안전하게 도착해보세요 !
- 친구들끼리 그룹을 만들고 모임을 효과적으로 관리해보세요 !

## 기능 소개

### 👍 목적지 설정과 함께 약속 생성!

- 목적지를 카테고리 별, 키워드 별 검색으로 손쉬운 설정이 가능합니다.
- 목적지와 함께 약속을 생성해 미리 목적지 정보를 공유할 수 있답니다!

### 🎯 약속장소 주변 핵심 스팟과 그룹원 중간지점 파악!

- 약속장소와 가까운 핵심 스팟 정보를 통해 쉽게 장소를 찾아보세요.
- 그룹원의 중간지점 또한 알 수 있어 쉽게 만날 수 있습니다!

### 🛣️ 실시간 길찾기 정보를 지도로 한눈에!

- 지도를 통해 목적지로 가는 길을 빠르게 알 수 있어요.
- 실시간으로 제공되는 경로를 따라가다 보면 목적지가 보인답니다!

### 🗺️ 그룹원들의 현재 이동 상태를 지도에서!

- 약속에 포함된 친구들의 현재 위치를 한 번에 확인할 수 있어요.
- 길을 잃은 친구를 바로 파악할 수 있답니다!

### 📱 그룹 통화를 통해 빠르게 경로 정보 공유 가능!

- 길을 찾기 어려운 경우 그룹 통화가 가능합니다.
- 다 같이 경로에 대한 정보를 공유해 빠르게 모여보세요!

## 사용 기술
|iOS|Backend|Infra/DevOps|Etc|
|:---:|:---:|:---:|:---:|
|<img src="https://img.shields.io/badge/swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"><br><img src="https://img.shields.io/badge/rxswift-F1007E?style=for-the-badge"><br><img src="https://img.shields.io/badge/rxcocoa-F1007E?style=for-the-badge"><br><img src="https://img.shields.io/badge/uikit-2396F3?style=for-the-badge&logo=uikit&logoColor=white"><br><img src="https://img.shields.io/badge/alamofire-F40D12?style=for-the-badge">|<img src="https://img.shields.io/badge/java-007396?style=for-the-badge&logo=OpenJDK&logoColor=white"><br><img src="https://img.shields.io/badge/springboot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white"><br><img src="https://img.shields.io/badge/springsecurity-6DB33F?style=for-the-badge&logo=springsecurity&logoColor=white"> <br><img src="https://img.shields.io/badge/hibernate-59666C?style=for-the-badge&logo=hibernate&logoColor=white"> <br> <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=MySQL&logoColor=white"><br><img src="https://img.shields.io/badge/junit5-25A162?style=for-the-badge&logo=junit5&logoColor=white"><br><img src="https://img.shields.io/badge/stomp-010101?style=for-the-badge">|<img src="https://img.shields.io/badge/amazons3-569A31?style=for-the-badge&logo=amazons3&logoColor=white"><br><img src="https://img.shields.io/badge/amazonec2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white"><br><img src="https://img.shields.io/badge/nginx-009639?style=for-the-badge&logo=nginx&logoColor=white"><br><img src="https://img.shields.io/badge/redis-DC382D?style=for-the-badge&logo=redis&logoColor=white"><br><img src="https://img.shields.io/badge/rabbitmq-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white"><br><img src="https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white"><br><img src="https://img.shields.io/badge/githubactions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white">|<img src="https://img.shields.io/badge/apple_login-000000?style=for-the-badge&logo=apple&logoColor=white"><br><img src="https://img.shields.io/badge/KAKAO_MAP_SDK_V2-FFCD00?style=for-the-badge&logo=kakao&logoColor=white"><br><img src="https://img.shields.io/badge/RX_KAKAO_OAUTH-FFCD00?style=for-the-badge&logo=kakao&logoColor=white"><br><img src="https://img.shields.io/badge/core_location-68BC71?style=for-the-badge"><br><img src="https://img.shields.io/badge/kakao_api-FFCD00?style=for-the-badge&logo=kakao&logoColor=white"><br><img src="https://img.shields.io/badge/tmap_api-D40E14?style=for-the-badge&logo=tvtime&logoColor=white"><br><img src="https://img.shields.io/badge/naver_api-03C75A?style=for-the-badge&logo=naver&logoColor=white">|


## 구현적 특징

### iOS
1. **MVVM-C 패턴 적용**
- 분리와 재사용성: 코드 재사용성, 테스트 용이성 향상시킨다.
- 데이터 바인딩: 데이터 처리 로직을 ViewModel에서 처리하여 ViewController를 간결하게 만든다.
- Coordinator를 통한 흐름제어: 앱의 화면전환 및 네비게이션 흐름을 관리해서 네비게이션 로직 중앙화한다.

2. **KakaoMap SDK V2 사용**
- 지도 및 경로 표시: 사용자에게 지도 표시, 경로 정보 제공한다.
- 사용자 경험 향상: 효율적인 경로 탐색 및 명확한 시각적 지도 인터페이스 제공한다.
- Localization: 한국지역 사용자에게 맞춤화된 지도서비스 제공한다.

3. **실시간 위치 공유를 위한 RxSwift, CoreLocation, WebSocket** 
- 반응형 프로그래밍: RxSwift를 사용해서 비동기적이고, 이벤트 기반의 데이터 흐름을 관리한다. 사용자 위치 변경과 같은 실시간 이벤트 효율적인 처리한다.
- 사용자 위치추적: CoreLocation을 통해 사용자의 실시간 위치 데이터를 추적한다.
- WebSocket을 통한 실시간 통신: WebSocket을 사용해서 서버와의 실시간 양방향 통신 구현으로 위치 데이터를 실시간으로 공유한다.

4. **애플 및 카카오 로그인을 위한 AuthenticationServices, RxKakaoOAuth 사용**
- Social 로그인 통합: AuthenticationServices을 사용한 Apple ID를 통한 로그인 및 RxKakaoOAuth를 사용한 Kakao 로그인 구현을 통해 사용자는 쉽게 로그인할 수 있다.
- 비동기 프로그래밍과 반응형 인터페이스: RxKakaoOAuth를 통해 로그인 프로세스의 비동기적인 특성 관리 및 사용자 인터페이스의 반응성을 향상시킨다.

## 멤버 소개
|홍성민|정호진|박다미|진주원|김승진|
|:----:|:----:|:----:|:----:|:----:|
|iOS|iOS|iOS|Server, DevOps|Server, DevOps|
|[@KKodiac](https://github.com/KKodiac)|[@HJ39](https://github.com/HJ39)|[@dami0806](https://github.com/dami0806)|[@jinjoo-lab](https://github.com/jinjoo-lab)|[@ohksj77](https://github.com/ohksj77)|
