# Binance-Assignment
This is coding assignment for Binance tech interview.
### Check list 
- [x] OrderBook
- [x] Market history
- [x] Unit Test
- [x] Loading state and error handling
- [x] Pull to refresh
- [x] Readme

## Architecture
This project using MVVM-Interactor architecture with below technical highlighted points :
- MVVM - Interactor as main architecture, powered by RxSwift behind the scene.
- CLEAN architecture which utilize Protocol Oriented Programing and Dependency Injection for Unit Test : RxViewModel, RxViewController, ...
- RxBlock for testing RxSwift Observable part and Mockingjay for stubbing network request
- CLEAN architecture with Interactor taking care of business logics and separate it from ViewModel which is responsible for UI logics
- XCTest for unit testing with mock and stub techniques
- SocketManager was built from scratch, integrated with RxSwift and using [StarScream](https://github.com/daltoniam/Starscream) as WebSocket client.
- Posibile to customize app theme at one place.
- Unit testing code coverage 
- Using cocoapods as package manager
![](https://user-images.githubusercontent.com/2222122/123654652-79602d80-d858-11eb-8ed1-2b8ea16dfdbd.png)

## Further enhancement
- UI Test

## Third parties libraries
- [RxSwift , RxCocoa , RxBlocking](https://github.com/ReactiveX/RxSwift)
- [StarScream](https://github.com/daltoniam/Starscream)
- [Mockingjay](https://github.com/kylef/Mockingjay)
- [Tabman](https://github.com/uias/Tabman)

## Screenshot
| Splash screen | Order Book | Market History
|-|-|-|
|![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 38 38](https://user-images.githubusercontent.com/2222122/123655498-3b173e00-d859-11eb-93e3-c9cefef7fc2a.png)|![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 34 31](https://user-images.githubusercontent.com/2222122/123655524-410d1f00-d859-11eb-85ef-ede8e6820e42.png) |![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 34 33](https://user-images.githubusercontent.com/2222122/123655542-436f7900-d859-11eb-9441-a69317c4f115.png)|

| Loading State | Request timeout | Internet offline |
| - | - | - |
| ![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 34 28](https://user-images.githubusercontent.com/2222122/123655515-3fdbf200-d859-11eb-8ecc-51a51afd25ef.png) | ![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 47 18](https://user-images.githubusercontent.com/2222122/123657328-e4126880-d85a-11eb-9966-cb51e4ce9e8c.png) | ![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 47 39](https://user-images.githubusercontent.com/2222122/123657379-eeccfd80-d85a-11eb-93cb-cd5f2a246cf6.png)|

