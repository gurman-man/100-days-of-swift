//
//  Levels.swift
//  Project26
//
//  Created by mac on 29.07.2025.
//

import Foundation

struct Levels {
    // бере останній збережений рівень із UserDefaults → ОК.
    var currentLevelIndex: Int = UserDefaults.standard.integer(forKey: "saveLevel")
    var levels = ["level1", "level2", "level3"]
    
    
    func currentLevel() -> String {
        return levels[currentLevelIndex]
    }
    

    mutating func goToNextLevel() -> Bool {
        // Перевірити, чи currentLevelIndex + 1 не виходить за межі масиву levels
        if currentLevelIndex + 1 < levels.count {
            currentLevelIndex += 1
            
            // Зберігаємо прогрес рівня
            UserDefaults.standard.set(currentLevelIndex, forKey: "saveLevel")
            return true
        } else {
            return false
        }
    }
    
    mutating func reset() {
        currentLevelIndex = 0
        UserDefaults.standard.set(0, forKey: "saveLevel")
        UserDefaults.standard.set(0, forKey: "score")
    }
}
