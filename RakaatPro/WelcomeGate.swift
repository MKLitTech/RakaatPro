//
//  WelcomeGate.swift
//  RakaatPro
//
//  Created by MKLit on 12/11/25.
//


import SwiftUI

struct WelcomeGate: View {
    @AppStorage("firstName") private var firstName: String = ""
    @AppStorage("lastName") private var lastName: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Welcome to RakaatPro")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Text("Please enter your name")
                    .font(.title2)
                    .foregroundColor(.gray)

                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)

                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)

                Button("Continue") {
                    // firstName is stored via AppStorage
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .foregroundColor(.white)
                .padding(.top, 10)
            }
            .padding()
        }
    }
}