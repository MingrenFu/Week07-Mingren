
import SwiftUI

struct ProfileScreen: View {
    let profileLinkNames: [String] = ["Favorite Music", "Playlist", "Follower", "Following", "Setting",]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ForEach(profileLinkNames, id: \.self) { profileLinkName in
                    ProfileLink(profileLinkName: profileLinkName)
                }
                Spacer()
            }
            .navigationBarTitle("Michael Fu")
            .navigationBarItems(
                leading: // Add our leading view
                Text("Welcome Back!")
                    .font(.body)
                    .foregroundColor(Color(.systemGray)),
                trailing: // Add trailing view
                Image("Michael")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            ) // Clip the image to a circle
        }
    }
    
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}


struct ProfileLink: View {
    let profileLinkName: String // Add parameter for profileLinkName
    var body: some View {
        NavigationLink(destination: Text("")) {
            VStack(spacing: 0) { // Embed both the HStack and Divider in a VStack
                HStack {
                    Text(profileLinkName)
                        .font(.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(.systemGray3))
                        .font(.system(size: 20))
                }
                .contentShape(Rectangle()) // Defining the shape of the HStack
                .padding(EdgeInsets(top: 17, leading: 21, bottom: 17, trailing: 21))
                
                Divider() // Add a divider
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
