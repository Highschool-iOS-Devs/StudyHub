//
//  ContentView.swift
//  StudyHub
//
//  Created by Dakshin Devanand on 8/22/20.
//  Copyright © 2020 Dakshin Devanand. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
struct ContentView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewRouter:ViewRouter
    @State private var hasCheckedAuth = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showSheet = false
    @State var myGroups = [Groups]()
    @State var hasIntroed = false
    @State var isIntroducing = false
    @State var settings = false
    @State var add = false
    @State var recentPeople = [Groups]()
    @State var recommendGroups = [Groups]()
    @State var images = [UIImage]()
    @State var profileImage = UIImage()
    @State var user = [User]()
    @State private var offset = CGSize.zero
    @State var hasLoaded: Bool = false
    @State var interests = [String]()
    @State var i = 0
    var body: some View {
        ZStack { 
            Color.white
                .edgesIgnoringSafeArea(.all)
                .onAppear{
                    self.checkAuth()
                   
            }
           
                if hasCheckedAuth {
                    Color.white
                        .edgesIgnoringSafeArea(.all)
                        .onAppear{
                            self.loadDMsData(){ userData in
                                //Get completion handler data results from loadData function and set it as the recentPeople local variable
                                self.recentPeople = userData ?? []
                               
        

                                hasLoaded = true
                            }
   
                            self.loadUserData(){ userData in
                                //Get completion handler data results from loadData function and set it as the recentPeople local variable
                                self.user = userData
                                self.loadMyGroupsData(){ userData in
                                    myGroups = userData ?? []
                                self.loadGroupsData(){ userData in
                                    //Get completion handler data results from loadData function and set it as the recentPeople local variable
                                    self.recommendGroups = userData!.removeDuplicates()
                                    hasLoaded = true
                                }
                                }
                            }

                          
                           
                    }
                if hasLoaded {
                    switch viewRouter.currentView {
                    case .registration:
                        RegistrationView()
                            .environmentObject(viewRouter)
                    case .login:
                        LoginView()
                       
                    case .chatList:
                        RecentsView2()
                            .environmentObject(userData)
                            .environmentObject(viewRouter)
                    case .profile:
                        ProfileView(profileImage: $profileImage, user: $user)
                            .environmentObject(userData)
                            .environmentObject(viewRouter)
                    case .home:
                        if !userData.isOnboardingCompleted {
                            Home()
                        } else {
                            Homev2(recentPeople: $recentPeople, recommendGroups: $recommendGroups, user: $user)
                            .environmentObject(userData)
                            .environmentObject(viewRouter)

                       
                        }
                    case .custom:
                        IntroCustomize(isNotOnboarding: true, interests: $interests, settings: $settings, add: $add)
                            .onDisappear() {
                                viewRouter.showTabBar = true
                            }
                    case .settings:
                        SettingView()
                            .environmentObject(viewRouter)
                            .environmentObject(userData)
                    case .leaderboard:
                        LeaderboardView()
                            .environmentObject(userData)
                            .environmentObject(viewRouter)
                    case .introView:
                        IntroView()
                            .onAppear() {
                                viewRouter.showTabBar = false
                            }
                            
                        }

                    }
            
            
                    
         
            // == true || viewRouter.currentView != .registration || viewRouter.currentView != .login 
            if viewRouter.showTabBar {
                VStack{
                    Spacer()
                    tabBarView()
                        
                }.transition(AnyTransition.move(edge: .bottom))
                    .animation(Animation.easeInOut)
            }
                
                }
        }
        .environmentObject(userData)
        .environmentObject(viewRouter)
        

}

    

    func loadUserData(performAction: @escaping ([User]) -> Void) {
        let db = Firestore.firestore()
     let docRef = db.collection("users").document(self.userData.userID)
        var userList:[User] = []
        //Get every single document under collection users
    
     docRef.getDocument{ (document, error) in
         
                let result = Result {
                 try document?.data(as: User.self)
                }
                switch result {
                    case .success(let user):
                        if let user = user {
                            userList.append(user)
                 
                        } else {
                            
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
     
            
              performAction(userList)
        }
    }
    func loadMyGroupsData(performAction: @escaping ([Groups]?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("groups")
        var groupList:[Groups] = []
        //Get every single document under collection users
        let queryParameter = docRef.whereField("members", arrayContains: userData.userID)
        queryParameter.getDocuments{ (querySnapshot, error) in
            if let querySnapshot = querySnapshot,!querySnapshot.isEmpty{
            for document in querySnapshot.documents{
                let result = Result {
                    try document.data(as: Groups.self)
                }
                switch result {
                    case .success(let group):
                        if var group = group {
                            i = 0
                            var array = group.groupName.components(separatedBy: " and ")
                            for a in array {
                                if a == userData.name {
                                    print(i)
                                    if i < array.count {
                                    array.remove(at: i)
                                }
                                }
                                i += 1
                            }
                            group.groupName = array.joined()
                            groupList.append(group)
                            
                        } else {
                            
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                
              
            }
            }
            else{
                performAction(nil)
            }
              performAction(groupList)
        }
        
        
    }
    func loadDMsData(performAction: @escaping ([Groups]?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("dms")
        var groupList:[Groups] = []
        //Get every single document under collection users
        let queryParameter = docRef.whereField("members", arrayContains: userData.userID)
        queryParameter.getDocuments{ (querySnapshot, error) in
            if let querySnapshot = querySnapshot,!querySnapshot.isEmpty{
            for document in querySnapshot.documents{
                let result = Result {
                    try document.data(as: Groups.self)
                }
                switch result {
                    case .success(let group):
                        if var group = group {
                            i = 0
                            var array = group.groupName.components(separatedBy: " and ")
                            for a in array {
                                if a == userData.name {
                                    print(i)
                                    if i < array.count {
                                    array.remove(at: i)
                                }
                                }
                                i += 1
                            }
                            group.groupName = array.joined()
                            groupList.append(group)
                            
                        } else {
                            
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                
              
            }
            }
            else{
                performAction(nil)
            }
              performAction(groupList)
        }
        
        
    }
    func loadGroupsData(performAction: @escaping ([Groups]?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("groups")
        var groupList:[Groups] = []
        if user.isEmpty {
            
        } else {
            if user[0].interests!.count < 0 {
            } else {
        //Get every single document under collection users
        
                let queryParameter = docRef.whereField("interests", arrayContains: "\(user[0].interests!.first!)").limit(to: 4)
                queryParameter.getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot,!querySnapshot.isEmpty{
            for document in querySnapshot.documents{
                let result = Result {
                    try document.data(as: Groups.self)
                }
                switch result {
                    case .success(let group):
                        if var group = group {
                           
                           
                            
                            
                                for person in group.members {
                                    var pairedBefore = false
                                    print(myGroups)
                                pairedBefore = checkPreviousPairing(from: myGroups, withUser: person, for: user[0].interests!.first!)
                               
                            
                            if !pairedBefore {
    //                        if user.isAvailable == true {
                                if group.members.count < 4 {
                                groupList.append(group)
                                }
    //                        }
                            }
                            }
                            
                        } else {
                            
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                
              
            }
            }
            else{
                performAction(nil)
            }
              performAction(groupList)
        }
        }
        }
    }
    
    func checkPreviousPairing(from myGroups: [Groups], withUser pairedUser: String, for interest: UserInterestTypes) -> Bool {
        var pairedInterests: [UserInterestTypes: [String]] = [.ACT: [], .APCalculus : [], .SAT: [], .Algebra2: []]
        for group in myGroups {
            for interest in group.interests {
                guard let interest = interest else { return false }
                var membersWithSameInterest: [String] = []
                for member in group.members {
                    membersWithSameInterest.append(member)
                }
                for member in membersWithSameInterest {
                    pairedInterests[interest]?.append(member)
                }
            }
        }
        guard let currentInterestPairings = pairedInterests[interest] else { return false }
        return currentInterestPairings.contains(pairedUser)
    }
    func downloadImages() {
        for people in myGroups {
            print(0)
            for members in people.members {
                if members != userData.userID {
                print(1)
           
                
            
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: members)
       
       // gs://study-hub-7540b.appspot.com/images
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        pathReference.getData(maxSize: 1 * 5000 * 5000) { data, error in
          if let error = error {
            print(error)
            // Uh-oh, an error occurred!
          } else {
            // Data for "images/island.jpg" is returned
            var image = UIImage(data: data!)
            images.append(image!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            //showLoadingAnimation = false
            }
          }
        }
        }
            }
        }
        
    }
    func checkAuth(){

            Auth.auth().addStateDidChangeListener { (auth, user) in
                if user != nil{
                    if userData.isOnboardingCompleted {

                        self.viewRouter.currentView = .home
                    }
                    else{
                        self.viewRouter.showTabBar = false
                        self.viewRouter.currentView = .introView
                    }
                    self.hasCheckedAuth = true

                
                }
                else {
                    self.viewRouter.currentView = .registration
                    self.hasCheckedAuth = true
                }
               
            }
        
         
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

