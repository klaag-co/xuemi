//
//  LoginView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 13/6/26.
//

import SwiftUI

struct LoginView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Color(uiColor: .systemGroupedBackground)
                    .overlay(alignment: .top) {
                        TimelineView(.animation) { timeline in
                            let time = timeline.date.timeIntervalSinceReferenceDate
                            let phase = Angle(degrees: time * 60).radians
                            
                            WaveShape(phase: phase)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .frame(height: geometry.size.height / 3)
                        .mask(
                            LinearGradient(
                                colors: [Color.white, Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(0.5)
                    }
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(.xuemi)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .mask {
                        Image(systemName: "app.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                    }
                
                Text("Welcome to Xuemi!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                CustomGlassEffectContainer {
                    googleButton
                    appleButton
                }
                
            }
            .padding()
        }
    }
    
    var googleButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button {
                    Task {
                        try? await authManager.signInWithGoogle()
                    }
                } label: {
                    Text("Sign in with Google")
                        .padding(8)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
            } else {
                Button {
                    Task {
                        try? await authManager.signInWithGoogle()
                    }
                } label: {
                    Text("Sign in with Google")
                        .padding(8)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .mask(Capsule())
            }
        }
    }
    
    var appleButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button {
                    Task {
                        try? await authManager.signInWithApple()
                    }
                } label: {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Sign in with Apple")
                    }
                    .padding(8)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                }
                .buttonStyle(.glass(.regular.tint(colorScheme == .light ? .black : .white).interactive()))
            } else {
                Button {
                    Task {
                        try? await authManager.signInWithApple()
                    }
                } label: {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Sign in with Apple")
                    }
                    .padding(8)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                }
                .buttonStyle(.borderedProminent)
                .tint(colorScheme == .light ? .black : .white)
                .mask(Capsule())
            }
        }
    }
}

#Preview {
    LoginView()
}
