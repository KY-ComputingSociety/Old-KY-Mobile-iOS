import Foundation
import SwiftUI

struct EditProfileView: View {
    
    @EnvironmentObject var imageArchive: ImageArchive
    let currentUser: User
    
    @Binding var errorMessage: String
    @Binding var showErrorMessage: Bool
    
    @Binding var isShowingEditProfile: Bool
    
    @State var editedUser: User
    @State private var newProfilePicture: UIImage = UIImage()
    @State private var isShowingImagePicker: Bool = false
    
    var body: some View {
        ZStack {
            Color("VeryLightGrey")
                .edgesIgnoringSafeArea(.all)
            
            Form {
                Section () {
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            if newProfilePicture != UIImage() {
                                UIImageToImage(uiImage: newProfilePicture)
                                    .userEditProfileImageModifier()
                            } else {
                                UIImageToImage(uiImage: imageArchive.searchArchive(id: currentUser.UID, url: currentUser.Image))
                                    .userEditProfileImageModifier()
                            }
                        }
                        Spacer()
                    }
                }
                
                Section () {
                    
                    NavigationLink(destination: editName) {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(editedUser.Name)
                                .foregroundColor(Color("NormalGrey"))
                        }
                    }
                    
                    NavigationLink(destination: editEmail) {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(editedUser.Email)
                                .foregroundColor(Color("NormalGrey"))
                        }
                    }
                    
                    NavigationLink(destination: editStudentID) {
                        HStack {
                            Text("Student ID")
                            Spacer()
                            Text(editedUser.StudentID)
                                .foregroundColor(Color("NormalGrey"))
                        }
                    }
                    
                    NavigationLink(destination: editBatch) {
                        HStack {
                            Text("Batch")
                            Spacer()
                            Text(editedUser.Batch)
                                .foregroundColor(Color("NormalGrey"))
                        }
                    }
                }
            }.sheet(isPresented: $isShowingImagePicker, content: {
                ImagePickerView(isPresented: $isShowingImagePicker,
                                selectedImage: $newProfilePicture)
            })
        }.navigationBarItems(trailing: Button(action: {
            if newProfilePicture != UIImage() {
                // Delete previous image
                FBStorage.deleteImage(location: "Users_ProfilePic",
                                      identifier: editedUser.UID) { (result) in
                    switch result {
                    case .failure (let error):
                        self.errorMessage = error.localizedDescription
                        self.showErrorMessage = true
                        
                    case .success:
                        // Upload new image
                        FBStorage.uploadImage(chosenImage: newProfilePicture,
                                              location: "Users_ProfilePic",
                                              identifier: editedUser.UID) { (result) in
                            switch result {
                            
                            case .failure (let error):
                                self.errorMessage = error.localizedDescription
                                self.showErrorMessage = true
                                
                            case .success (let url):
                                
                                // Saves the image to imageArchive
                                imageArchive.modifyImageArchive(id: editedUser.UID, uiImage: newProfilePicture, .replace)
                                editedUser.Image = url.absoluteString
                            }
                        }
                    }
                }
            } else if !editedUser.equalTo(currentUser) {
                print("Edited user is different from current user")
            }
            
            // Save new user's new details into Firestore
            FBProfile.editUserDetails(uid: editedUser.UID,
                                  info: editedUser.userToDict()) { (result) in
                switch result {
                case .failure (let error):
                    self.errorMessage = error.localizedDescription
                    self.showErrorMessage = true
                    
                case .success:
                    print("Successfully saved new details of users!")
                }
            }
            
            isShowingEditProfile = false
        }) {
            Text("Save")
        }.disabled((newProfilePicture == UIImage()) && editedUser.equalTo(currentUser)))
    }
    
    var editName: some View {
        NavigationView{
            VStack (spacing: 0) {
                TextField("Enter your full name", text: $editedUser.Name)
                    .autocapitalization(.words)
                    .frame(width: 300, height: 30)
                
                Divider()
                    .frame(width: 300, height: 2)
                    .background(editedUser.isNameEmpty() ? Color("VeryLightGrey") : Color("Green"))
                
            }
        }
    }
    
    var editEmail: some View {
        NavigationView {
            VStack (spacing: 0) {
                TextField("Enter your email", text: $editedUser.Email)
                    .frame(width: 300, height: 30)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                Divider()
                    .frame(width: 300, height: 2)
                    .background(editedUser.isEmailValid() ? Color("Green") : Color("VeryLightGrey"))
            }
        }
    }
    
    
    var editStudentID: some View {
        NavigationView {
            VStack (spacing: 0) {
                TextField("Enter your Student ID", text: $editedUser.StudentID)
                    .frame(width: 300, height: 30)
                    .autocapitalization(.none)
                    .keyboardType(.numbersAndPunctuation)
                
                Divider()
                    .frame(width: 300, height: 2)
                    .background(editedUser.isStudentIDValid() ? Color("Green") : Color("VeryLightGrey"))
            }
        }
    }
    
    var editBatch: some View {
        NavigationView {
            VStack (spacing: 0) {
                TextField("Enter your batch", text: $editedUser.Batch)
                    .frame(width: 300, height: 30)
                    .autocapitalization(.none)
                    .keyboardType(.numbersAndPunctuation)
                
                Divider()
                    .frame(width: 300, height: 2)
                    .background(editedUser.isBatchValid() ? Color("Green") : Color("VeryLightGrey"))
            }
        }
    }
}

//struct UserEditProfileImage: View {
//    @ObservedObject var imageLoader = ImageLoaderViewModel()
//    let url: String
//    let placeholder: String
//
//    init(url: String, placeholder: String = "placeholder") {
//        self.url = url
//        self.placeholder = placeholder
//        self.imageLoader.downloadImage(url: self.url)
//    }
//
//    var body: some View {
//        if let data = self.imageLoader.downloadedData {
//            return Image(uiImage: UIImage(data: data) ?? UIImage()).userEditProfileImageModifier()
//        } else {
//            return Image("placeholder").userEditProfileImageModifier()
//        }
//    }
//}

extension Image {
    func userEditProfileImageModifier() -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 0.5))
   }
}
