//
//  LoginView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 8/7/25.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @ObservedObject private var authmanager: AuthenticationManager = .shared
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .overlay(alignment: .top) {
                    waveBackground
                        .frame(height: UIScreen.main.bounds.height / 3)
                        .mask(
                            LinearGradient(
                                colors: [Color.white, Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(0.5)
                }
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image("xuemi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .mask(RoundedRectangle(cornerRadius: 45))
                    .shadow(radius: 10)
                
                Text("Welcome to Xuemi!")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    ZStack{
                        LinearGradient(
                            gradient: .init(colors: [Color.customteal, Color.customblue.opacity(0.66)]),
                            startPoint: .init(x: 0.0, y: 0.0),
                            endPoint: .init(x: 0.75, y: 0.75)
                        )
                        .mask(
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 120, height: 45, alignment: .center)
                                .blur(radius: 10)
                        )
                        .padding(.top, 20)
                        Button {
                            authmanager.signIn()
                        } label: {
                            Text("Sign in with Google")
                                .font(.system(size: 20))
                                .padding()
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                        }
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                gradient: .init(colors: [Color.customteal, Color.customblue.opacity(0.75)]),
                                startPoint: .init(x: -0.33, y: -0.33),
                                endPoint: .init(x: 0.66, y: 0.66)
                            ))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(height: 100)
                    
                    Button("Continue as Guest") {
                        authmanager.isGuest = true
                        withAnimation {
                            authmanager.isLoggedIn = true
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
    
    var waveBackground: some View {
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
    }
}

struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat = 20
    var frequency: CGFloat = 1.5
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0, y: height))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * frequency * .pi * 2 + phase)
            let y = height / 2 + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        return path
    }
}
