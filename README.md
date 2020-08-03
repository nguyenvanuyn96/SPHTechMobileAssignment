[![codecov](https://codecov.io/gh/nguyenvanuyn96/SPHTechMobileAssignment/branch/master/graph/badge.svg)](https://codecov.io/gh/nguyenvanuyn96/SPHTechMobileAssignment)

# SPHTechMobileAssignment
This is the project that I did in the test examination when interviewing at WonderLabs company.

## Requirements: 
* Xcode Version 11.3 with Swift 5.0

## Building
Open Terminar, and cd to folder which contains the Podfile of this project. 
Then run
```
$ sudo gem install cocoapods
$ pod install --repo-update
```
Open SPHTechMobile-Assignment.xcworkspace in Xcode and build...

## Architecture concepts/framework used here:
* VIPER 
* RxCocoa
* RxSwift: For using binding/functional programming
* RxDataSource: For binding datasource into TableView/CollectionView
* RealmSwift: For storage data for the offline usage
* RxRealm
* SnapKit: For auto layout by programmatically
* Reusable: For easily register and dequeueForReusableCell

## ScreenShoot:
<img src="https://github.com/nguyenvanuyn96/SPHTechMobileAssignment/blob/master/screenshot_main.png" width="326">  <img src="https://github.com/nguyenvanuyn96/SPHTechMobileAssignment/blob/master/screenshot_pulltorefresh.png" width="326"> <img src="https://github.com/nguyenvanuyn96/SPHTechMobileAssignment/blob/master/screenshot_loadmore.png" width="326"> <img src="https://github.com/nguyenvanuyn96/SPHTechMobileAssignment/blob/master/screenshot_viewdetail_all.png" width="326"> <img src="https://github.com/nguyenvanuyn96/SPHTechMobileAssignment/blob/master/screenshot_viewdetail_down.png" width="326"> 

## Author:
* Name: Uy Nguyen
* Email: nguyenvanuyn96@gmail.com
