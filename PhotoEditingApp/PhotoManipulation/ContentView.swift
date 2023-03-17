//  ContentView.swift

import SwiftUI
import AVKit
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins


struct Item : Identifiable {
    var id = UUID()
    var urlStr:String
    var name:String
}

// Array of image url strings
let imageArray = [
    "https://res.cloudinary.com/streethub/image/upload/v1582220740/brand/5de79ed16da6d30003f79b00/zh1snrsot6zjpe6frkp8.jpg",
    "https://photographylife.com/wp-content/uploads/2012/08/Hitech-100mm-Modular-Filter-Holder-Vignetting-28mm.jpg",
    "https://i.stack.imgur.com/k9zOF.png",
    "https://www.tutorialspoint.com/opencv/images/gaussian_blur.jpg",
    "https://upload.wikimedia.org/wikipedia/commons/e/e6/Usm-unsharp-mask.png",
    "https://www.chasejarvis.com/wp-content/uploads/2012/03/parissepia.jpg",
]

// Read in an image from the array of url strings
func imageFor( index: Int) -> UIImage {
    let urlStr = imageArray[index % imageArray.count]
    return imageFor(string: urlStr)
}

// Read in an image from a url string
func imageFor(string str: String) -> UIImage {
    let url = URL(string: str)
    let imgData = try? Data(contentsOf: url!)
    let uiImage = UIImage(data:imgData!)
    return uiImage!
}


// Array of image url strings
let imageItems:[Item] = [

//Item(urlStr: imageArray[0], name:"Pixellate", filter: setFilter (CIFilter.gaussianBlur())),
    Item(urlStr: imageArray[0], name:"Pixellate"),
    Item(urlStr: imageArray[1], name:"Vignette"),
    Item(urlStr: imageArray[2], name:"Edges"),
    Item(urlStr: imageArray[3], name:"Gaussian Blur"),
    Item(urlStr: imageArray[4], name:"Unsharp Mask"),
    Item(urlStr: imageArray[5], name:"Sepia Tone"),
]

func startUp() {
  print("Hello world")
}

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            NavigationView {
                List {
                    ForEach(imageItems) { item in
                        NavigationLink(destination: ItemDetail(item: item)) {
                            ItemRow(item: item)
                        }
                    }
                }
                .navigationTitle("Filters")
                .onAppear {
                    startUp()
                }
            }
            .tabItem {
                Image(systemName: "music.note.house.fill")
                Text("Home")
            }
            
//            Text("Search Screen")
//            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
//            Text("Profile Screen")
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

struct ItemRow: View {
    var item:Item
    var body: some View {
        HStack {
            Image(uiImage: imageFor(string: item.urlStr))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:100.0, height: 100.0)
                .cornerRadius(5)
            Text(item.name)
            Spacer()
        }
    }
}

struct ItemDetail: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    @State private var showingFilterSheet = false
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    class ImageSaver: NSObject {
        var successHandler: (() -> Void)?
        var errorHandler: ((Error) -> Void)?
        
        func writeToPhotoAlbum(image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }
        
        @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                errorHandler?(error)
            } else {
                successHandler?()
            }
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        print ("The filter is set")
        currentFilter = filter
        loadImage()
    }
    
    var item:Item
    var body: some View {
        VStack {
            Image(uiImage: imageFor(string: item.urlStr))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:320, height: 320)
                .cornerRadius(7)
                .padding(.bottom, 100)
            Text(item.name)
                .font(.title)
                .fontWeight(.semibold)
                .position(x: 200, y: -70)
            HStack {
                Text("Intensity")
                Slider(value: $filterIntensity)
                    .onChange(of: filterIntensity) { _ in applyProcessing() }
            }
            .padding(.vertical)
            .padding(.horizontal, 25.0)
            .padding(.bottom, 100)
            .onAppear {
                let filterName = item.name
                print(filterName)
                switch filterName {
                case "Pixellate":
                    setFilter(CIFilter.pixellate())
                    print("Pixellate filter")
                case "Vignette":
                    setFilter(CIFilter.vignette())
                    print("Vignette filter")
                case "Edges":
                    setFilter(CIFilter.edges())
                    print("Edges filter")
                case "Gaussian Blur":
                    setFilter(CIFilter.gaussianBlur())
                    print("Gaussian filter")
                case "Unsharp Mask":
                    setFilter(CIFilter.unsharpMask())
                    print("Unsharp filter")
                case "Sepia Tone":
                    setFilter(CIFilter.sepiaTone())
                    print("Seepia Tone filter")
                default:
                    print("No filter is selected")
                }
            }
        }
    }
}

// moving bar animation
    //            .onAppear (perform: {
    //                    print("1")
    //                    switch item.name {
    //                    case "Pixellate":
    //                        setFilter(CIFilter.pixellate())
    //                        print("1")
    //                    case "Spanish":
    //                     Text("Hola!")
    //                    case "Chinese":
    //                            Text("你好!")
    //                    default:
    //                         print("1")
    //                    }
    //                })

//struct AudioPlayerView: View {
//    @State var progress: Double = 0
//    @State var duration: Double = 0
//
//    var body: some View {
//        VStack {
//            Slider(value: $progress, in: 0...duration)
//                .padding()
//            HStack {
//                Text("\(formattedTime(progress))")
//                    .frame(width: 50)
//                Spacer()
//                Text("\(formattedTime(duration))")
//                    .frame(width: 50)
//            }
//        }
//        .onAppear {
//            guard let url = Bundle.main.url(forResource: "my-audio-file", withExtension: "mp3") else {
//                fatalError("Failed to find audio file")
//            }
//            let player = AVPlayer(url: url)
//            duration = player.currentItem?.duration.seconds ?? 0
//        }
//    }
//
//    private func formattedTime(_ time: Double) -> String {
//        let minutes = Int(time / 60)
//        let seconds = Int(time) % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

