//
//  IntroPages.swift
//  StudyHub
//
//  Created by Jevon Mao on 9/17/20.
//  Copyright © 2020 Dakshin Devanand. All rights reserved.
//

import SwiftUI


struct IntroView: View {
    @State var interests = [String]()
    @State var add: Bool = false
    @State var settings: Bool = false
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var userData: UserData

        
    
    var body: some View {
        ZStack {
           
            TabView {
                IntroPage(titleText: "Welcome", bodyText: "Welcome to Studeo, a place to study with others and gain motivation. Build the future you've dreamed of, one study session at a time.", image: "studying_drawing")
                    
                
                IntroPage(titleText: "Study", bodyText: "Gain motivation by tracking your progress with a study timer and compete with others.", image: "mentor_drawing" )
                IntroPage(titleText: "Motivate", bodyText: "Join a community deticated to motivating each other to study.", image: "timer_drawing")
                RegistrationView()
                    
                    .ignoresSafeArea()
                
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            .transition(.opacity)
            .animation(.easeInOut(duration: 1.5))
            .ignoresSafeArea()

       
        }
    }
}

struct IntroPages_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}

