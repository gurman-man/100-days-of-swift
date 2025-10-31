# 🗺️ City Explorer 🗺️ 

[Project 16](https://www.hackingwithswift.com/read/16/overview) from the [100 Days of Swift course](https://www.hackingwithswift.com/100) by [Hacking With Swift](https://www.hackingwithswift.com/).

>An iOS app that displays famous world capitals and custom map locations using MapKit, allowing users to switch between map types, explore annotations, and open related Wikipedia pages directly in an integrated web view..

## Contents

|                      Day                      | Contents                                                                                                                                                                                                                                                                          |
|:---------------------------------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [60](https://www.hackingwithswift.com/100/60) | <ul><li>[Setting up](https://www.hackingwithswift.com/read/16/1/setting-up)</li><li>[Up and running with MapKit](https://www.hackingwithswift.com/read/16/2)</li><li>[Annotations and accessory views: MKPinAnnotationView](https://www.hackingwithswift.com/read/16/3)</li></ul> |
| [61](https://www.hackingwithswift.com/100/61) | <ul><li>[Wrap up](https://www.hackingwithswift.com/read/16/4)</li><li>[Review for Project 16: Capital Cities](https://www.hackingwithswift.com/review/hws/project-16-capital-cities)</li></ul>                                                                                    |


## Challenges

Taken from [here](https://www.hackingwithswift.com/read/16/4):

>1. Try typecasting the return value from `dequeueReusableAnnotationView()` so that it's an `MKPinAnnotationView`. Once that’s done, change the `pinTintColor` property to your favorite `UIColor`.
>2. Add a `UIAlertController` that lets users specify how they want to view the map. There's a `mapType` property that draws the maps in different ways. For example, `.satellite` gives a satellite view of the terrain.
>3. Modify the callout button so that pressing it shows a new view controller with a web view, taking users to the Wikipedia entry for that city.

## Screenshots

<div align="center">
  <img src="./Screenshots/1.png" alt="Main screen" width="244">
  <img src="./Screenshots/2.png" alt="Map types" width="244">
  <img src="./Screenshots/3.png" alt="Hybrid type" width="244">
  <img src="./Screenshots/4.png" alt="Detail screen" width="244">
</div>

---

## Installation

1. Clone this repository:  
   ```bash
   git clone https://github.com/gurman-man/100-days-of-swift.git
   ```
2. Open `Project16.xcodeproj` in Xcode
3. Run on the simulator or your device
