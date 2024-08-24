import SwiftUI
import UIKit

struct ChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(id: UUID().uuidString, username: "Davlen", text: "Dude what are we thinking about the Buckeyes week one...", imageName: "Davlen"),
        ChatMessage(id: UUID().uuidString, username: "Triloni", text: "Let's go over some stats.", imageName: "Triloni"),
        ChatMessage(id: UUID().uuidString, username: "Nick", text: "Davlen, your app says take the over.", imageName: "Nick"),
        ChatMessage(id: UUID().uuidString, username: "Davlen", text: "I'm thinking the same. Our offense looks strong.", imageName: "Davlen"),
        ChatMessage(id: UUID().uuidString, username: "Triloni", text: "True, but the defense might struggle. The opponent's QB is solid.", imageName: "Triloni"),
        ChatMessage(id: UUID().uuidString, username: "Nick", text: "It could be a high-scoring game. Should be fun to watch!", imageName: "Nick")
    ]
    @State private var newMessage: String = ""
    @State private var showingImagePicker = false

    var body: some View {
        VStack {
            // Display messages
            List(messages) { message in
                ChatMessageRow(message: message)
            }
            
            // Input field, photo icon, and send button
            HStack {
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                        .padding(.leading, 10)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePickerView()
                }
                
                TextField("Enter your message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Text("Send")
                        .fontWeight(.bold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.trailing, 10)
            }
            .padding(.bottom)
        }
        .navigationTitle("Gameday Chat")
        .onAppear(perform: loadMessages)
    }

    private func sendMessage() {
        // Simulate sending message
        let newMsg = ChatMessage(id: UUID().uuidString, username: "Davlen", text: newMessage, imageName: "Davlen") // Placeholder for current user
        messages.append(newMsg)
        newMessage = ""
    }

    private func loadMessages() {
        // Load existing messages (dummy implementation for now)
    }
}

struct ChatMessage: Identifiable {
    var id: String
    var username: String
    var text: String
    var imageName: String
}

struct ChatMessageRow: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // User profile image
            Image(message.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.red, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(message.username)
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text(message.text)
                    .font(.body)
            }
        }
        .padding(.vertical, 8)
    }
}

// Image picker implementation
struct ImagePickerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView

        init(parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Handle the selected image
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
