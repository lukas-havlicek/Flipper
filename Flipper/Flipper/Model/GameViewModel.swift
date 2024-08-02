//
//  GameViewModel.swift
//  Flipper
//
//  Created by Lukas Havlicek on 03.03.2022.
//

import SwiftUI
import UIKit

class GameViewModel: ObservableObject {
  
  init() {
    highestScore = defaults.integer(forKey: scoreKey)
    playersName = defaults.string(forKey: nameKey) ?? ""
    mainColor = loadColor()
  }
  
  private let scoreKey = "Score"
  private let nameKey = "Name"
  private let colorKey = "Color"
  private let defaults = UserDefaults.standard
  
  @Published var loadButtonActivated = true
  @Published var startButtonActivated = false
  @Published var loadButton = false
  @Published var startButton = false
  @Published var showFreeBallAlert = false
  @Published var points = 0
  @Published var colorChange = false
  
  @Published var playersName = "" {
    didSet {
      defaults.set(playersName, forKey: nameKey)
    }
  }
  
  @Published var highestScore = 0 {
    didSet {
      defaults.set(highestScore, forKey: scoreKey)
    }
  }
  
  @Published var mainColor: UIColor = .metalGray {
    didSet {
      colorChange = true
      loadButtonActivated = true
      startButtonActivated = false
      saveColor(color: mainColor)
    }
  }
  
  func clearHighestScore() {
    highestScore = 0
  }
  
  func writeHighestScore() {
    if points > highestScore {
      highestScore = points
    }
  }
  
  private func saveColor(color: UIColor) {
    let cgColor = color.cgColor
    guard let components = cgColor.components else { return }
    defaults.setValue(components, forKey: colorKey)
  }
  
  private func loadColor() -> UIColor {
    guard let metalCGColor = UIColor.metalGray.cgColor.components else {
      print("metalGray error")
      return .metalGray
    }
    guard let skyCGColor = UIColor.skyBlue.cgColor.components else {
      print("skyBlue error")
      return .metalGray
    }
    guard let deepCGColor = UIColor.deepPurple.cgColor.components else {
      print("deepPurple error")
      return .metalGray
    }
    
    guard let colorArray = defaults.array(forKey: colorKey) as? [CGFloat] else { return .metalGray }
    guard colorArray.count == 4 else { return .metalGray }
    
    if colorArray == metalCGColor {
      return .metalGray
    } else if colorArray == skyCGColor {
      return .skyBlue
    } else if colorArray == deepCGColor {
      return .deepPurple
    } else {
      return .metalGray
    }
  }
  
}
