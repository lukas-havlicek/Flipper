//
//  Extensions.swift
//  Flipper
//
//  Created by Lukas Havlicek on 18.02.2022.
//

import SwiftUI

extension CGVector {
  static func *(_ lhs: CGVector, _ rhs: CGFloat) -> CGVector {
    CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
  }
}

extension UIColor {
  static let metalGray = UIColor(named: "metalGray") ?? UIColor.gray
  static let skyBlue = UIColor(named: "skyBlue") ?? UIColor.blue
  static let deepPurple = UIColor(named: "deepPurple") ?? UIColor.purple
  static let lightYellow = UIColor(red: 1.00, green: 1.00, blue: 0.75, alpha: 1.00)
}

@available(iOS, deprecated: 15.0, message: "Use built-in APIs instead")
extension View {
  
  func background<T: View>(alignment: Alignment = .center, @ViewBuilder content: () -> T) -> some View {
    background(Group(content: content), alignment: alignment)
  }
  
  func overlay<T: View>(alignment: Alignment = .center, @ViewBuilder content: () -> T) -> some View {
    overlay(Group(content: content), alignment: alignment)
  }
  
}
