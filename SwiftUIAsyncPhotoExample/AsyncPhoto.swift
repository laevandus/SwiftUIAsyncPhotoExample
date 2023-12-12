//
//  AsyncPhoto.swift
//  AsyncPhotoExample
//
//  Created by Toomas Vahter on 04.12.2023.
//

import SwiftUI

struct AsyncPhoto<ID, Content, Progress, Placeholder>: View where ID: Equatable, Content: View, Progress: View, Placeholder: View {
    @State private var phase: Phase = .loading

    let id: ID
    let data: (ID) async -> Data?
    let scaledSize: CGSize
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    @ViewBuilder let progress: () -> Progress

    init(id value: ID = "",
         scaledSize: CGSize,
         data: @escaping (ID) async -> Data?,
         content: @escaping (Image) -> Content,
         progress: @escaping () -> Progress = { ProgressView() },
         placeholder: @escaping () -> Placeholder = { Color.secondary }) {
        self.id = value
        self.content = content
        self.data = data
        self.placeholder = placeholder
        self.progress = progress
        self.scaledSize = scaledSize
    }

    var body: some View {
        VStack {
            switch phase {
            case .success(let image):
                content(image)
            case .loading:
                progress()
            case .placeholder:
                placeholder()
            }
        }
        .frame(width: scaledSize.width, height: scaledSize.height)
        .task(id: id, {
            await self.load()
        })
    }

    @MainActor func load() async {
        phase = .loading
        if let image = await prepareScaledImage() {
            phase = .success(image)
        }
        else {
            phase = .placeholder
        }
    }

    private func prepareScaledImage() async -> Image? {
        guard let photoData = await data(id) else { return nil }
        guard let originalImage = UIImage(data: photoData) else { return nil }
        let scaledImage = await originalImage.scaled(toFill: scaledSize)
        guard let finalImage = await scaledImage.byPreparingForDisplay() else { return nil }
        return Image(uiImage: finalImage)
    }
}

extension AsyncPhoto {
    enum Phase {
        case success(Image)
        case loading
        case placeholder
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    return Group {
        AsyncPhoto(id: "",
                   scaledSize: CGSize(width: 64, height: 64),
                   data: { _ in
            UIImage.filled(size: CGSize(width: 500, height: 500), fillColor: .systemOrange).pngData()
        },
                   content: { image in
            image
                .resizable()
                .scaledToFit()
        })
        AsyncPhoto(scaledSize: CGSize(width: 64, height: 64),
                   data: { _ in
            UIImage.filled(size: CGSize(width: 500, height: 500), fillColor: .systemCyan).pngData()
        },
                   content: { image in
            image
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
        })
        AsyncPhoto(scaledSize: CGSize(width: 64, height: 64),
                   data: { _ in nil },
                   content: { $0 })
    }
}
