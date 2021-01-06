//
//  ProfilePics.swift
//  StudyHub
//
//  Created by Andreas Ink on 10/20/20.
//  Copyright © 2020 Dakshin Devanand. All rights reserved.
//

import SwiftUI
import FirebaseStorage
struct ProfilePic: View {
    var name: String
    var size: CGFloat
    @State var isTimer = false
    var id = ""
    @State var image = UIImage()
    var body: some View {
        ZStack {
            Color.clear
                .onAppear() {
                    getProfileImage()
                }
            if !isTimer {
            VStack {
            Image(uiImage: image)
                .resizable()
                .frame(width:size,height:size)
                .clipShape(Circle())
                .overlay(
                            Circle()
                                .stroke(LinearGradient(gradient: Gradient(colors: [Color("Secondary"), Color("Primary")]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                        )
             Text(name)
            }
            } else {
              
            }
        } .padding()
            
    }
    func getProfileImage() {
      

        // Create a storage reference from our storage service
        
            
      
        let storage = Storage.storage().reference().child("User_Profile/\(id)")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storage.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
           print(error)
          } else {
            // Data for "images/island.jpg" is returned
            image = UIImage(data: data!)!
          }
        }
    }
}

//struct ProfilePic_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfilePic()
//    }
//}
