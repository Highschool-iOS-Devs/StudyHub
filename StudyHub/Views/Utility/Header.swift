//
//  Header.swift
//  StudyHub
//
//  Created by Andreas Ink on 8/22/20.
//  Copyright © 2020 Dakshin Devanand. All rights reserved.
//

import SwiftUI

struct Header: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewRouter:ViewRouter
    @Binding var showTimer: Bool
    var body: some View {
        HStack {
            VStack {
                HStack {
                Text("Hello,")
                    .font(Font.custom("Montserrat-Regular", size: 17, relativeTo: .headline))
                    .foregroundColor(Color("Text"))
                    .opacity(25)
                    .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                Text("\(userData.name)")
                    .frame(minWidth: 150, alignment: .leading)
                    .font(Font.custom("Montserrat-SemiBold", size: 22, relativeTo: .title))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.leading)
                    Spacer()
                }
            } .padding(.horizontal)
            Spacer()
            
            Button(action: {viewRouter.currentView = .profile}) {
                
                ProfileRingView(size: 55)
            
            } .padding(.trailing, 22)
            
            Button(action: { withAnimation(.easeInOut(duration: 0.5)) {
                    self.showTimer = true }}) {
                ZStack {
                    Color.white
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 3)
                        .overlay(
                            Image(systemName: "timer")
                                .foregroundColor(.black)
                                .font(.system(size: 20)))
                    
                }
            }
            
        }
        .frame(height: 120)
        .padding(.horizontal, 15)
        .padding(.top, 20)
        .background(BlurView(style: .systemMaterial))
        .border(Color("Background").opacity(0.3), width:0.5)
        .edgesIgnoringSafeArea(.all)



        
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header(showTimer: .constant(true))
    }
}

