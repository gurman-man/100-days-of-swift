# 🔍 Debugging 🔍

[Project 18](https://www.hackingwithswift.com/read/18/overview) from the [100 Days of Swift course](https://www.hackingwithswift.com/100) by [Hacking With Swift](https://www.hackingwithswift.com/).

>Practiced basic Swift debugging using print() statements, verified conditions with assert(), paused and inspected code execution with breakpoints, and analyzed UI layouts using view debugging tools.

## Contents

|                      Day                      | Contents                                                                                                                                                                                                                                                                                                                                                                                                            |
|:---------------------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [64](https://www.hackingwithswift.com/100/64) | <ul><li>[Setting up](https://www.hackingwithswift.com/read/18/1/setting-up)</li><li>[Basic Swift debugging using print()](https://www.hackingwithswift.com/read/18/2)</li><li>[Debugging with assert()](https://www.hackingwithswift.com/read/18/3)</li><li>[Debugging with breakpoints](https://www.hackingwithswift.com/read/18/4)</li><li>[View debugging](https://www.hackingwithswift.com/read/18/5)</li></ul> |
| [65](https://www.hackingwithswift.com/100/65) | <ul><li>[Wrap up](https://www.hackingwithswift.com/read/18/6)</li><li>[Review for Project 18: Debugging](https://www.hackingwithswift.com/review/hws/project-18-debugging)</li></ul>                                                                                                                                                                                                                                |


## Challenges

Taken from [here](https://www.hackingwithswift.com/read/18/6):

>1. Temporarily try adding an exception breakpoint to project 1, then changing the call to `instantiateViewController()` so that it uses the storyboard identifier “Bad” – this will fail, but your exception breakpoint should catch it.
>2. In project 1, add a call to `assert()` in the `viewDidLoad()` method of DetailViewController.swift, checking that `selectedImage` always has a value.
>3. Go back to project 5, and try adding a conditional breakpoint to the start of the `submit()` method that pauses only if the user submits a word with six or more letters.
