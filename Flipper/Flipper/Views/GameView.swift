//
//  GameView.swift
//  Flipper
//
//  Created by Lukas Havlicek on 18.02.2022.
//

import SwiftUI
import SpriteKit

struct GameView: View {
  
  @ObservedObject var gameViewModel: GameViewModel
  
  @State private var geometrySize = CGSize.zero
  @State private var showOptions = false
  @State private var showNameTextFieldAlert = false
  @State private var dragOffset = UIScreen.main.bounds.width + 10
  
  private let spriteOptions: SpriteView.Options = [.allowsTransparency, .ignoresSiblingOrder, .shouldCullNonVisibleNodes]
  private let spriteDebugOptions: SpriteView.DebugOptions = []//[.showsPhysics]
  private let screenWidth = UIScreen.main.bounds.width
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Color(uiColor: gameViewModel.mainColor)
          .ignoresSafeArea()
        SpriteView(scene: scene, options: spriteOptions, debugOptions: spriteDebugOptions)
          .padding(8)
          .gesture(hideOptions)
        loadButton
          .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topTrailing)
        startButton
          .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomTrailing)
        freeBallAlert
          .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        pointsScore
          .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
        optionsButton
          .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomLeading)
          .gesture(hideOptions)
        OptionsView(gameViewModel: gameViewModel, showNameTextFieldAlert: $showNameTextFieldAlert)
          .offset(x: dragOffset, y: 0)
          .frame(width: geometry.size.width, height: geometry.size.height)
          .gesture(optionsDrag)
        if showNameTextFieldAlert {
          NameTextFieldAlertView(showNameTextFieldAlert: $showNameTextFieldAlert, title: "Set your player's name") { name in
            gameViewModel.playersName = name
          }
        }
      }
      .onAppear {
        geometrySize = geometry.size
      }
    }
  }
  
  var scene: SKScene {
    let scene = GameScene(gameViewModel: gameViewModel)
    scene.anchorPoint = CGPoint(x: 0, y: 0)
    scene.size = geometrySize
    return scene
  }
  
  var hideOptions: some Gesture {
    TapGesture()
      .onEnded { _ in
        if dragOffset == screenWidth - 200 {
          withAnimation(.easeInOut) {
            dragOffset = screenWidth + 10
          }
        }
        showNameTextFieldAlert = false
      }
  }
  
  var optionsDrag: some Gesture {
    DragGesture()
      .onChanged { value in
        if value.translation.width > 0 {
          withAnimation {
            dragOffset = screenWidth - 200 + value.translation.width
          }
        }
      }
      .onEnded { value in
        if value.translation.width > 20 {
          withAnimation {
            dragOffset = screenWidth + 10
          }
        } else {
          withAnimation {
            dragOffset = screenWidth - 200
          }
        }
      }
  }
  
  var optionsButton: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(gameViewModel.playersName)
      Button {
        if dragOffset == screenWidth - 200 {
          withAnimation(.easeInOut) {
            dragOffset = screenWidth
          }
        } else {
          withAnimation(.easeInOut) {
            dragOffset = screenWidth - 200
          }
        }
      } label: {
        Image(systemName: "line.3.horizontal.circle")
          .imageScale(.large)
          .padding(.bottom, UIScreen.main.bounds.width * 2 > UIScreen.main.bounds.height ? 12 : 0)
      }
    }
    .padding(.horizontal)
    .foregroundColor(.white)
  }
  
  var pointsScore: some View {
    VStack(alignment: .leading) {
      Text("Points:")
      Text("\(gameViewModel.points)")
        .font(.title)
    }
    .foregroundColor(.white)
    .padding(.horizontal, 8)
  }
  
  var freeBallAlert: some View {
    Text("Free new ball")
      .font(.caption)
      .foregroundColor(.black)
      .padding(8)
      .background(RoundedRectangle(cornerRadius: 5)
        .foregroundColor(Color(white: 0.9))
      )
      .padding()
      .padding(.trailing, 35)
      .padding(.bottom, 100)
      .opacity(gameViewModel.showFreeBallAlert ? 1 : 0)
      .animation(.easeInOut, value: gameViewModel.showFreeBallAlert)
  }
  
  var loadButton: some View {
    Button {
      gameViewModel.startButtonActivated = true
      gameViewModel.loadButtonActivated = false
      gameViewModel.loadButton = true
      gameViewModel.points = 0
    } label: {
      Text("Load Ball")
        .font(.system(size: 14))
        .foregroundColor(gameViewModel.loadButtonActivated ? .black : .clear)
        .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
        .background(Capsule().fill(gameViewModel.loadButtonActivated ? Color.white : Color(uiColor: gameViewModel.mainColor)))
    }
    .disabled(!gameViewModel.loadButtonActivated)
    .padding(.horizontal, 8)
  }
  
  var startButton: some View {
    Button {
      gameViewModel.startButton = true
      gameViewModel.startButtonActivated = false
      gameViewModel.showFreeBallAlert = false
    } label: {
      Circle()
        .frame(width: 30, height: 30)
        .foregroundColor(gameViewModel.startButtonActivated ? Color(uiColor: .red) : Color(uiColor: gameViewModel.mainColor))
        .overlay(Circle()
          .strokeBorder(gameViewModel.startButtonActivated ? Color.white : Color(white: 0.3))
          .frame(width: 30, height: 30)
        )
    }
    .disabled(!gameViewModel.startButtonActivated)
    .padding(.horizontal, 5)
    .padding(.bottom, UIScreen.main.bounds.width * 2 > UIScreen.main.bounds.height ? 12 : 0)
  }
  
}













struct GameView_Previews: PreviewProvider {
  static var previews: some View {
    GameView(gameViewModel: GameViewModel())
  }
}
