//
//  OptionsView.swift
//  Flipper
//
//  Created by Lukas Havlicek on 23.03.2022.
//

import SwiftUI

struct OptionsView: View {
  
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var gameViewModel: GameViewModel
  @State private var showClearAlert = false
  @Binding var showNameTextFieldAlert: Bool
  
  private let screenBounds = UIScreen.main.bounds
  
  var body: some View {
    HStack(spacing: 0) {
      
      VStack(alignment: .leading, spacing: 30) {
        Text("Options")
          .font(.system(size: 25, weight: .bold))
          .padding(.top, 50)
        
        colorOptions
        
        if !gameViewModel.playersName.isEmpty {
          Text(gameViewModel.playersName)
            .font(.title2)
        }
        
        highestScoreView
          .alert(Text("Clear highest score?"), isPresented: $showClearAlert) {
            Button("Yes", role: .destructive) {
              gameViewModel.clearHighestScore()
            }
            Button("No", role: .cancel) {}
          }
        
        settingPlayersName
        
        Spacer()
      }
      .padding(.horizontal)
      .frame(width: 200, height: screenBounds.height)
      .background(backgroundColor.shadow(color: shadowColor, radius: 3))
      
      Color.gray
    }
    .ignoresSafeArea()
  }
  
  var shadowColor: Color {
    if colorScheme == .dark {
      Color(white: 0.3)
    } else {
      Color(white: 0.7)
    }
  }
  
  var backgroundColor: Color {
    if colorScheme == .dark {
      Color.black
    } else {
      Color.white
    }
  }
  
  var settingPlayersName: some View {
    VStack(alignment: .leading, spacing: 10) {
      Button {
        showNameTextFieldAlert = true
      } label: {
        Text("Set your name")
      }
      Button {
        gameViewModel.playersName = ""
      } label: {
        Text("Clear name")
          .font(.caption)
      }
    }
  }
  
  var highestScoreView: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Highest score: ")
        Text("\(gameViewModel.highestScore)")
      }
      Button {
        showClearAlert = true
      } label: {
        Text("Clear highest score")
          .font(.caption)
      }
    }
  }
  
  var strokeColor: Color {
    if colorScheme == .dark {
      Color.white
    } else {
      Color.black
    }
  }
  
  var colorOptions: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Main color")
      HStack(spacing: 20) {
        
        Button {
          gameViewModel.mainColor = .metalGray
        } label: {
          ZStack {
            Circle()
              .stroke(gameViewModel.mainColor == .metalGray ? strokeColor : Color.clear)
              .frame(width: 35, height: 35)
            Circle()
              .fill(Color(uiColor: .metalGray))
              .frame(width: 30, height: 30)
          }
        }
        
        Button {
          gameViewModel.mainColor = .skyBlue
        } label: {
          ZStack {
            Circle()
              .stroke(gameViewModel.mainColor == .skyBlue ? strokeColor : Color.clear)
              .frame(width: 35, height: 35)
            Circle()
              .fill(Color(uiColor: .skyBlue))
              .frame(width: 30, height: 30)
          }
        }
        
        Button {
          gameViewModel.mainColor = .deepPurple
        } label: {
          ZStack {
            Circle()
              .stroke(gameViewModel.mainColor == .deepPurple ? strokeColor : Color.clear)
              .frame(width: 35, height: 35)
            Circle()
              .fill(Color(uiColor: .deepPurple))
              .frame(width: 30, height: 30)
          }
        }

      }
      Text("Attention! Change of color terminates current game.")
        .font(.caption2)
        .foregroundColor(.red)
    }
  }
  
}




struct OptionsView_Previews: PreviewProvider {
  static var previews: some View {
    OptionsView(gameViewModel: GameViewModel(), showNameTextFieldAlert: .constant(false))
  }
}
