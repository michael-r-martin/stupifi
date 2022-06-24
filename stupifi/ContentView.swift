//
//  ContentView.swift
//  stupifi
//
//  Created by Michael Martin on 30/03/2022.
//

import SwiftUI
import CoreData

@available(iOS 15.0, *)
struct ContentView: View, BalanceFetchDelegate {
    
    @State private var xAngle = Angle.zero
    @State private var yAngle = Angle.zero
    @State private var translationX = 0.0
    
    @State private var darkModeEnabled = false
    
    @State private var balance = "0.00"
    
    @Binding var walletAddress: String
    
    @EnvironmentObject var settings: AppSettings
    
    let nfcHelper = NFCHelper()
    let balanceFetcher = BalanceFetcher()
    
    var body: some View {
        
        VStack() {
            Spacer()
            
            Spacer()
            
            TextField("Address/ENS", text: $walletAddress)
            
            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(LinearGradient(colors: [.pink, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 300,
                           height: 200,
                           alignment: .center)
                
                DebitCard(balance: balance, xAngle: xAngle, isFront: true)
                    .frame(width: 294, height: 194, alignment: .center)
                    .rotation3DEffect(yAngle, axis: (x: 1, y: 0, z: 0), anchor: .center)
                    .rotation3DEffect(xAngle, axis: (x: 0, y: 1, z: 0), anchor: .center)
                    .animation(Animation.spring(response: 1, dampingFraction: 0.5, blendDuration: 0.3))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let deltaX = 147-Float(value.location.x)
                                let deltaY = 97-Float(value.location.y)
                                
                                xAngle = -Angle(degrees: Double(atanf(deltaX)))*3
                                yAngle = Angle(degrees: Double(atanf(deltaY)))*3
                            }
                            .onEnded { value in
                                xAngle = Angle.zero
                                yAngle = Angle.zero
                            })
                
                Spacer()
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .fill(LinearGradient(colors: [.pink, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 50, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                HStack() {
                    Circle().frame(width: 44, height: 44, alignment: .center)
                        .foregroundColor(.white)
                        .gesture(
                            DragGesture().onChanged { value in
                                translationX += value.location.x
                            }.onEnded({ _ in
                                if translationX > 150 {
                                    nfcHelper.activateSession()
                                }

                                translationX = 0
                            })
                        )
                        .overlay {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                        }
                    .transformEffect(CGAffineTransform(translationX: translationX, y: 0))

                    Spacer()
                }.padding(.horizontal, 34)
            }.opacity(0)
            
            Toolbar(xAngle: $xAngle)
                .padding(.bottom, 50)
        }.background(settings.darkModeBackground).ignoresSafeArea()
            .environmentObject(settings)
            .onAppear {
                print("running")
                
                balanceFetcher.delegate = self
                
                balanceFetcher.fetchBalance(walletAddressOrENS: "0x08df2d9356A9F693287024C01119C5d49195C559")
            }
    }
    
    func didAttemptFetch(success: Bool) {
        self.balance = balanceFetcher.fetchedBalance
    }

}

struct DebitCard: View {
    var balance: String = "0"
    var xAngle = Angle.zero
    
    var isFront = true
    
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        RoundedRectangle(cornerRadius: 36, style: .continuous)
            .fill(settings.darkModeBackground)
            .frame(width: 294, height: 194, alignment: .center)
            .shadow(color: settings.darkModeBackground, radius: 5, x: 0, y: 0)
            .overlay(
                VStack {
                    HStack {
                        Circle()
                            .fill(LinearGradient(colors: [.pink, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50, alignment: .leading)
                        .padding(EdgeInsets(top: 20, leading: 24, bottom: 0, trailing: 0))
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text(balance)
                            .foregroundColor(settings.darkModeTextColor)
                            .font(Font.custom("Jost-Bold", size: 26))
                        .padding(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 0))
                        Spacer()
                    }
                    
                }.rotation3DEffect(xAngle, axis: (x: 0, y: 1, z: 0), anchor: .center)
            )
            .environmentObject(settings)
    }
}

class AppSettings: ObservableObject {
    @Published var darkModeBackground = Color.white
    @Published var darkModeTextColor = Color.darkGray
}

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environmentObject(AppSettings())
        }
    }
}

struct Toolbar: View, CustomNFCDelegate {
    
    @Binding var xAngle: Angle
    @State private var darkModeEnabled = false
    @State private var darkModeButtonRotation = Angle.zero
    
    @EnvironmentObject var settings: AppSettings
    
    let nfcHelper = NFCHelper()
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
//            Button(action: {
//                darkModeEnabled.toggle()
//                if darkModeEnabled {
//                    settings.darkModeBackground = Color.darkGray
//                    settings.darkModeTextColor = Color.white
//                } else {
//                    settings.darkModeBackground = Color.white
//                    settings.darkModeTextColor = Color.darkGray
//                }
//            }) {
//                Image(systemName: "moon")
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(LinearGradient(colors: [.pink, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 40)
//                    .clipShape(Circle())
//                    .font(Font.system(size: 16))
//            }
            Button(action: {
                xAngle += Angle(degrees: 180)
            }) {
                Image(systemName: "arrow.forward.circle.fill")
                    .padding()
                    .foregroundColor(.white)
                    .background(LinearGradient(colors: [.pink, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 40)
                    .clipShape(Circle())
                    .font(Font.system(size: 16))
            }
            Button(action: {
                nfcHelper.activateSession()
            }) {
                Image(systemName: "star.fill")
                    .padding()
                    .foregroundColor(.white)
                    .background(LinearGradient(colors: [.pink, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 40)
                    .clipShape(Circle())
                    .font(Font.system(size: 16))
            }
            Image(systemName: "moon.fill")
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(colors: [.pink, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 40)
                .clipShape(Circle())
                .font(Font.system(size: 16))
                .gesture(
                    DragGesture().onChanged({ value in
//                        let changedAmount = Double(value.location.x/20)
//                        darkModeButtonRotation -= Angle(degrees: changedAmount)
                    })
                        .onEnded({ value in
                            darkModeButtonRotation += Angle(degrees: 360)
                            darkModeEnabled.toggle()
                            if darkModeEnabled {
                                settings.darkModeBackground = Color.darkGray
                                settings.darkModeTextColor = Color.white
                            } else {
                                settings.darkModeBackground = Color.white
                                settings.darkModeTextColor = Color.darkGray
                            }
                        })
                )
                .rotation3DEffect(darkModeButtonRotation, axis: (x: 0, y: 1, z: 0))
                .animation(Animation.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.3))
            Button(action: {
                nfcHelper.activateSession()
            }) {
                Image(systemName: "gearshape.fill")
                    .padding()
                    .foregroundColor(.white)
                    .background(LinearGradient(colors: [.pink, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 40)
                    .clipShape(Circle())
                    .font(Font.system(size: 16))
            }
        }
        .padding()
        .onAppear(perform: {
            nfcHelper.delegate = self
        })
    }
}

extension Toolbar {
    func sessionDidFail() {
        print("session failed")
    }
    
    func didCompleteSuccessfulSession(sessionType: NFCType) {
        
    }
}
