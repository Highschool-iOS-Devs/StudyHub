//
//  RecentsView2.swift
//  StudyHub
//
//  Created by Andreas Ink on 9/25/20.
//  Copyright © 2020 Dakshin Devanand. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RecentsView2: View {
//    @State var allGroups: [Groups] = []
//    @State var recentPeople: [User] = []
//    @State var recentGroups: [Groups] = []
    var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible())]
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject var groupModel = ChatViewModel()
    @State var add: Bool = false
    @State var settings: Bool = false
    @State var showTimer = false
    @Binding var myMentors:[Groups]
    @Binding var timerLog: [TimerLog]

    var body: some View {
        NavigationView{
            ZStack{
                Color("Primary").edgesIgnoringSafeArea(.all)
                ZStack(alignment: .top) {
                    
                    VStack {
                        ScrollView{
                            RecentChatTextRow(add: $add)
                                .environmentObject(userData)
                                .padding(.top)
                            Spacer()
                            if groupModel.allGroups == []{
                                Text("You are not in any study group yet,\n\nUse the add button to pair. 🙌").font(.custom("Montserrat Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 0.27, green: 0.89, blue: 0.98, alpha: 1)))
                                .multilineTextAlignment(.center)
                                    .frame(width: 250)
                                    .frame(height:425)
                            }
                            else{
                                VStack(spacing: 20) {
                                    ForEach(groupModel.recentGroups){ group in
                                        NavigationLink(
                                            destination:ChatView(group: group)
                                                        .environmentObject(userData)
                                            ){
                                            
                                            RecentGroupRowSubview(group: group, profilePicture: Image("demoprofile"))
                                                .padding(.horizontal, 20)
                                                .environmentObject(UserData.shared)
                                            
                                        }
                                        
                                     
                                    }
                                    Spacer()
                                }
                                .padding(.vertical)
                               
                                
                            }
                            Spacer()
                            VStack{
                                AllGroupTextRow()
                                    .environmentObject(userData)
                                LazyVGrid(columns: gridItemLayout, spacing: 40){
                                    ForEach(groupModel.allGroups){group in
                                        NavigationLink(destination: ChatView(group: group)
                                                        .environmentObject(userData)){
                                            RecentChatGroupSubview(group: group)
                                                .environmentObject(UserData.shared)
                                        }
                                    
                                    }
                                }

                            }
                            HStack{
                                
                                    Text("Mentors").font(.custom("Montserrat Bold", size: 24)).foregroundColor(Color("Primary"))
                                Spacer()
                                
                            } .padding()
                            LazyVGrid(columns: gridItemLayout, spacing: 40) {
                                ForEach(myMentors){ group in
                                    NavigationLink(
                                        destination:ChatView(group: group)
                                                    .environmentObject(userData)
                                           
                                        ){
                                    RecentChatGroupSubview(group: group)
                                        .environmentObject(UserData.shared)
                                        
                                }
                                }
                            }
                            Spacer(minLength: 200)
                        }
                      
                    
                    }
                    .frame(width: screenSize.width, height: screenSize.height)
                    .background(Color("Background"))
                    .cornerRadius(20)
                    .offset(y: 15)

                    if showTimer {
                        VStack {
                            TimerView(showingView: $showTimer, timerLog: $timerLog)
                                .padding(.top, 110)
                                .transition(.move(edge: .bottom))
                                .onAppear {
                                    self.viewRouter.showTabBar = false
                                }
                                .onDisappear {
                                    self.viewRouter.showTabBar = true
                            }
                        }
                    }
            }
     
            }
            .fullScreenCover(isPresented: $add){
                PairingView(settings: $settings, add: $add, myGroups: $groupModel.allGroups, groupModel: groupModel)
            }

        }
        .blur(radius: showTimer ? 20 : 0)
        .accentColor(Color("Primary"))
        .animation(.none)
        .onAppear{
            groupModel.userData = userData
            groupModel.getAllGroups(){groupModel.allGroups=$0}
            groupModel.getRecentGroups{groupModel.recentGroups=$0}
            groupModel.recentPeople = groupModel.getRecentPeople()
        }

    
        
    }

    
    func loadMessageData(){
        let db = Firestore.firestore()
//        let docRef = db.collection("message/\(group.groupID)/messages").order(by: "sentTime", descending: true).limit(to: 1)
//        docRef.getDocuments{ (document, error) in
//                        if let document = document, !document.isEmpty{
//
//
//                        for document in document.documents{
//
//                                   let result = Result {
//                                       try document.data(as: MessageData.self)
//                                   }
//                                   switch result {
//                                       case .success(let messageData):
//                                           if let messageData = messageData {
//                                            messageArray.append(self.parseMessageData(messageData: messageData))
//                                           } else {
//
//                                               print("Document does not exist")
//                                           }
//                                       case .failure(let error):
//                                           print("Error decoding user: \(error)")
//                                       }
//                  }
//                }
//                        print(messageArray)
//                        self.messages = messageArray
//
//        }
    }



        
        
    }

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


