# 🧩 Extension Scripts 🧩

[Project 19](https://www.hackingwithswift.com/read/19/overview) from the [100 Days of Swift course](https://www.hackingwithswift.com/100) by [Hacking With Swift](https://www.hackingwithswift.com/).

>An iOS Safari extension that allows users to create, save, and run custom JavaScript snippets directly on web pages — featuring script management, persistent storage with UserDefaults, JSON encoding, and a clean, interactive UI for editing and selecting scripts.

## Contents

|                      Day                      | Contents                                                                                                                                                                                                                                                                                                                                 |
|:---------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [67](https://www.hackingwithswift.com/100/67) | <ul><li>[Setting up](https://www.hackingwithswift.com/read/19/1/setting-up)</li><li>[Making a shell app](https://www.hackingwithswift.com/read/19/2)</li><li>[Adding an extension: NSExtensionItem](https://www.hackingwithswift.com/read/19/3)</li><li>[What do you want to get?](https://www.hackingwithswift.com/read/19/4)</li></ul> |
| [68](https://www.hackingwithswift.com/100/68) | <ul><li>[Establishing communication](https://www.hackingwithswift.com/read/19/5)</li><li>[Editing multiline text with UITextView](https://www.hackingwithswift.com/read/19/6)</li><li>[Fixing the keyboard: NotificationCenter](https://www.hackingwithswift.com/read/19/7)</li></ul>                                                    |
| [69](https://www.hackingwithswift.com/100/69) | <ul><li>[Wrap up](https://www.hackingwithswift.com/read/19/8)</li><li>[Review for Project 19: JavaScript Injection](https://www.hackingwithswift.com/review/hws/project-19-javascript-injection)</li></ul>                                                                                                                               |


## Challenges

Taken from [here](https://www.hackingwithswift.com/read/19/8):

>1. Add a bar button item that lets users select from a handful of prewritten example scripts, shown using a `UIAlertController` – at the very least your list should include the example we used in this project.
>2. You're already receiving the URL of the site the user is on, so use UserDefaults to save the user's JavaScript for each site. You should convert the URL to a URL object in order to use its host property.
>3. For something bigger, let users name their scripts, then select one to load using a UITableView.

## Screenshots

<div align="center">
  <img src="./Screenshots/1.png" alt="Main screen" width="244">
  <img src="./Screenshots/2.png" alt="JavaScript console" width="244">
  <img src="./Screenshots/3.png" alt="JavaScript executed" width="244">
  <img src="./Screenshots/4.png" alt="My scripts" width="244">
</div>

---

## Installation

1. Clone this repository:  
   ```bash
   git clone https://github.com/gurman-man/100-days-of-swift.git
   ```
2. Open `Project19.xcodeproj` in Xcode
3. Run on the simulator or your device
