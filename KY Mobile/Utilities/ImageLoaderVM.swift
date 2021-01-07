import SwiftUI

// Downloads an image from a URL
class ImageLoaderViewModel: ObservableObject {
    @Published var downloadedData: Data?
    
    func downloadImage(url: String) {
        guard let imageURL = URL(string: url) else {
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.downloadedData = data
            }
        }.resume()
    }
}


func UIImageToImage(uiImage: UIImage) -> Image {
    if uiImage == UIImage() {
        return Image("placeholder")
    } else {
        return Image(uiImage: uiImage)
    }
}
