# Binance-Assignment
This is coding assignment for Binance tech interview.

## Specifications
- Xcode 12.5
- Swift 5

## Checklist
- [x] OrderBook
- [x] Market history
- [x] Real-time data update with websocket
- [x] Unit Test
- [x] Loading state and error handling
- [x] Pull to refresh
- [x] Readme
- [ ] UI Test

## Project overview
This project using MVVM-Interactor architecture with below technical highlights :
- MVVM - Interactor as main architecture, powered by RxSwift behind the scene.
- Utilize Protocol Oriented Programing and Dependency Injection for Unit Test.
- RxBlock for testing RxSwift Observable part and Mockingjay for stubbing network request.
- CLEAN architecture with Interactor taking care of business logics and separate it from ViewModel which is responsible for UI logics.
- XCTest for unit testing with mock and stub techniques.
- SocketManager was built from scratch, integrated with [RxSwift](https://github.com/ReactiveX/RxSwift) and using [StarScream](https://github.com/daltoniam/Starscream) as WebSocket client.
- Use propertyWrapper to handle threadsafe in read/write property [@ThreadSafety](https://github.com/untouchable741/Binance-Assignment/blob/develop/BinanceOrderBook/Utilities/ThreadSafety.swift)
- Possibility to customize app theme at one place.
- Using cocoapods as package manager.
- Unit testing code coverage.

![Screen Shot 2021-06-28 at 10 21 14 PM](https://user-images.githubusercontent.com/2222122/123661983-35245b80-d85f-11eb-9c5b-83e7590ecd4d.png)

## Third parties libraries
- [RxSwift , RxCocoa , RxBlocking](https://github.com/ReactiveX/RxSwift)
- [StarScream](https://github.com/daltoniam/Starscream)
- [Mockingjay](https://github.com/kylef/Mockingjay)
- [Tabman](https://github.com/uias/Tabman)

## Screenshot
| Splash screen | Order Book | Market History
|-|-|-|
|![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 38 38](https://user-images.githubusercontent.com/2222122/123655498-3b173e00-d859-11eb-93e3-c9cefef7fc2a.png)|![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 34 31](https://user-images.githubusercontent.com/2222122/123655524-410d1f00-d859-11eb-85ef-ede8e6820e42.png) |![Simulator Screen Shot - iPhone 12 Pro - 2021-06-28 at 21 34 33](https://user-images.githubusercontent.com/2222122/123655542-436f7900-d859-11eb-9441-a69317c4f115.png)|
