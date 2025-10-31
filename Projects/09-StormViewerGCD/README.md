# Storm Viewer GCD 💨

[Project 9](https://www.hackingwithswift.com/read/9/overview) from the [100 Days of Swift course](https://www.hackingwithswift.com/100) by [Hacking With Swift](https://www.hackingwithswift.com/).

>An app that demonstrates the use of Grand Central Dispatch (GCD) to perform background data loading and UI updates efficiently, showcasing how to manage concurrency and improve app responsiveness.

## Contents

|                      Day                      | Contents                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|:---------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [39](https://www.hackingwithswift.com/100/39) | <ul><li>[Setting up](https://www.hackingwithswift.com/read/9/1/setting-up)</li><li>[Why is locking the UI bad?](https://www.hackingwithswift.com/read/9/2)</li><li>[GCD 101: async()](https://www.hackingwithswift.com/read/9/3)</li><li>[Back to the main thread: DispatchQueue.main](https://www.hackingwithswift.com/read/9/4)</li><li>[Easy GCD using performSelector(inBackground:)](https://www.hackingwithswift.com/read/9/5)</li></ul> |
| [40](https://www.hackingwithswift.com/100/40) | <ul><li>[Wrap up](https://www.hackingwithswift.com/read/9/6)</li><li>[Review for Project 9: Grand Central Dispatch](https://www.hackingwithswift.com/review/hws/project-9-grand-central-dispatch)</li></ul>                                                                                                                                                                                                                                    |


## Challenges

Taken from [here](https://www.hackingwithswift.com/read/9/6/wrap-up):

>1. Modify [project 1](https://github.com/gurman-man/100-days-of-swift/tree/main/Projects/09-StormViewerGCD/Project1(GCD-ChallengeTask)) so that loading the list of NSSL images from our bundle happens in the background. Make sure you call `reloadData()` on the table view once loading has finished!
>2. Modify [project 8](https://github.com/gurman-man/100-days-of-swift/tree/main/Projects/08-LetterQuest) so that loading and parsing a level takes place in the background. Once you’re done, make sure you update the UI on the main thread!
>3. Modify [project 7](https://github.com/gurman-man/100-days-of-swift/tree/main/Projects/07-WhitehousePetitions) so that your filtering code takes place in the background. This filtering code was added in one of the challenges for the project, so hopefully you didn't skip it!

## Screenshots

<div align="center">
  <img src="./Screenshots/1.png" alt="Mainscreen" width="488">
</div>

---

## Installation

1. Clone this repository:  
   ```bash
   git clone https://github.com/gurman-man/100-days-of-swift.git
   ```
2. Open `Project1(GCD-ChallengeTask).xcodeproj` in Xcode
3. Run on the simulator or your device
