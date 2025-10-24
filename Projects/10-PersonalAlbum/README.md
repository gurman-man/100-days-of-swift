# Personal Album 🌇

[Project 10](https://www.hackingwithswift.com/read/10/overview) from the [100 Days of Swift course](https://www.hackingwithswift.com/100) by [Hacking With Swift](https://www.hackingwithswift.com/).

>An iOS app that lets users add, name, and manage photos in a grid-based collection view — supporting image import from the camera or photo library, local storage, and easy renaming or deletion.

## Contents

|                      Day                      | Contents                                                                                                                                                                                                                                                                         |
|:---------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [42](https://www.hackingwithswift.com/100/42) | <ul><li>[Setting up](https://www.hackingwithswift.com/read/10/1/setting-up)</li><li>[Designing UICollectionView cells](https://www.hackingwithswift.com/read/10/2)</li><li>[UICollectionView data sources](https://www.hackingwithswift.com/read/10/3)</li></ul>                 |
| [43](https://www.hackingwithswift.com/100/43) | <ul><li>[Importing photos with UIImagePickerController](https://www.hackingwithswift.com/read/10/4)</li><li>[Custom subclasses of NSObject](https://www.hackingwithswift.com/read/10/5)</li><li>[Connecting up the people](https://www.hackingwithswift.com/read/10/6)</li></ul> | 
| [44](https://www.hackingwithswift.com/100/44) | <ul><li>[Wrap up](https://www.hackingwithswift.com/read/10/7/wrap-up)</li><li>[Review for Project 10: Names To Faces](https://www.hackingwithswift.com/review/hws/project-10-names-to-faces)</li></ul>                                                                           |


## Challenges

Taken from [here](https://www.hackingwithswift.com/read/10/7/wrap-up):

>1. Add a second `UIAlertController` that gets shown when the user taps a picture, asking them whether they want to rename the person or delete them.
>2. Try using `picker.sourceType = .camera` when creating your image picker, which will tell it to create a new image by taking a photo. This is only available on devices (not on the simulator) so you might want to check the return value of `UIImagePickerController.isSourceTypeAvailable()` before trying to use it!
>3. Modify project 1 so that it uses a collection view controller rather than a table view controller. I recommend you keep a copy of your original table view controller code so you can refer back to it later on.

## Screenshots

<div align="center">
  <img src="./Screenshots/1.png" alt="Main screen" width="325">
  <img src="./Screenshots/2.png" alt="Edited screen" width="325">
  <img src="./Screenshots/3.png" alt="Options screen" width="325"> 
</div>

---

## Installation

1. Clone this repository:  
   ```bash
   git clone https://github.com/gurman-man/100-days-of-swift.git
   ```
2. Open `Project10.xcodeproj` in Xcode
3. Run on the simulator or your device
