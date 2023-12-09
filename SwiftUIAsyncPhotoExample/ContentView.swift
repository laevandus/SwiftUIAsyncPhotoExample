//
//  ContentView.swift
//  SwiftUIAsyncPhotoExample
//
//  Created by Toomas Vahter on 09.12.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedColor: UIColor?
    static let colors: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemYellow, .systemCyan]

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                AsyncPhoto(id: selectedColor,
                           scaledSize: CGSize(width: 48, height: 48),
                           data: { selectedColor in
                    guard let selectedColor else { return nil }
                    return UIImage.filled(size: CGSize(width: 1000, height: 1000),
                                          fillColor: selectedColor).pngData()
                },
                           content: { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                },
                           placeholder: {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                })
                VStack(alignment: .leading, spacing: 8) {
                    Text("Toomas Vahter")
                    Text("Love programming in Swift")
                        .font(.caption2)
                }
            }
            .padding()
            .background(.orange, in: RoundedRectangle(cornerRadius: 8))

            Button("Reload") {
                var newColor: UIColor?
                repeat {
                    newColor = Self.colors.randomElement()!
                } while selectedColor == newColor
                selectedColor = newColor
            }
            Button("Clear") {
                selectedColor = nil
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
