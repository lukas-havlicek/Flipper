//
//  InitialView.swift
//  Flipper
//
//  Created by Lukas Havlicek on 08.07.2024.
//

import SwiftUI

struct InitialView: View {
  
  @StateObject var gameViewModel = GameViewModel()
  @State private var scale: CGFloat = 1
  @State private var scale2: CGFloat = 1
  @State private var rotation: Double = 0
  @State private var navLink = false
  
  var backgroundGradient: LinearGradient {
    LinearGradient(colors: [Color("lightBackground"), Color("darkBackground")], startPoint: .bottomLeading, endPoint: .topTrailing)
  }
  
  var body: some View {
    
      if !navLink {
        ZStack {
          backgroundGradient
            .ignoresSafeArea()
          VStack {
            Text("one\nfinger\nflipper")
              .multilineTextAlignment(.leading)
              .font(.system(size: 40, weight: .black))
              .scaleEffect(scale)
              .rotation3DEffect(.degrees(rotation), axis: (x: 1.0, y: 1.0, z: 0.0))
              .animation(.easeIn(duration: 1).delay(2), value: scale)
            
            Text("\"play with one finger only\"")
              .font(.headline)
              .padding(.top, 26)
              .scaleEffect(scale2)
              .animation(.easeIn(duration: 1).delay(2), value: scale2)
          }
          .foregroundStyle(.white)
        }
        .onAppear {
          scale = 0
          scale2 = 1.2
          rotation = 360
          moveOn()
        }
      } else {
        GameView(gameViewModel: gameViewModel)
      }
    
  }
  
  private func moveOn() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
      navLink = true
    }
  }
  
}

#Preview {
  InitialView()
}
