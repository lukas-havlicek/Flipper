//
//  NameTextFieldAlertView.swift
//  Flipper
//
//  Created by Lukas Havlicek on 26.03.2022.
//

import SwiftUI

struct NameTextFieldAlertView: View {
  
  @Environment(\.colorScheme) var colorScheme
  @Binding var showNameTextFieldAlert: Bool
  @State private var name = ""
  
  let title: String
  let setName: (String) -> Void
  
  var body: some View {
    VStack {
      Text(title)
        .font(.system(size: 16, weight: .semibold))
        .padding()
      TextField(text: $name, prompt: Text("Your name")) { Text("") }
        .labelsHidden()
        .disableAutocorrection(true)
        .textFieldStyle(.roundedBorder)
        .padding()
        .onSubmit {
          setName(name)
          showNameTextFieldAlert = false
        }
      HStack {
        Button {
          setName(name)
          showNameTextFieldAlert = false
        } label: {
          Text("OK")
            .padding()
        }
        .disabled(name.isEmpty)
        Divider()
          .frame(height: 40)
        Button {
          showNameTextFieldAlert = false
        } label: {
          Text("Cancel")
            .foregroundColor(.red)
            .padding()
        }
      }
    }
    .padding()
    .frame(width: 250)
    .background(RoundedRectangle(cornerRadius: 15)
      .fill(colorScheme == .light ? Color.white : Color.black)
      .shadow(color: Color.gray, radius: 5, x: 0, y: 0)
    )
  }
}
