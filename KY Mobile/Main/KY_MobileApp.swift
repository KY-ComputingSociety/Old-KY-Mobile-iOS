import SwiftUI
import Firebase

@main
struct KY_MobileApp: App {
    
    var currentUser: CurrentUserViewModel
    var downloadedImages: ImageArchive
    
    init() {
        // Connect the app to Firebase when the app is opened
        FirebaseApp.configure()
        self.currentUser = CurrentUserViewModel()
        self.downloadedImages = ImageArchive()
    }
    
    var body: some Scene {
        WindowGroup {
            // Allow currentUserInfo to be accessible throughout the entire app
            ViewController()
                .environmentObject(currentUser)
                .environmentObject(downloadedImages)
        }
    }
}
