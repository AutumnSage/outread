//
//  flashcard.swift
//  Outread
//
//  Created by Dhruv Sirohi on 19/2/2024.
//

import SwiftUI

struct ArticleFlashcardView: View {
    let article: Article
    @State private var currentIndex: Int = 0
    private var contentSegments: [String] {
        article.content.rendered.components(separatedBy: ". ").filter { !$0.isEmpty }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if contentSegments.indices.contains(currentIndex) {
                    FlashcardView(text: contentSegments[currentIndex])
                        .gesture(
                            DragGesture().onEnded { value in
                                // Detect vertical swipe and update currentIndex accordingly
                                let dragThreshold: CGFloat = 50.0
                                if value.translation.height > dragThreshold && currentIndex > 0 {
                                    currentIndex -= 1
                                } else if value.translation.height < -dragThreshold && currentIndex < contentSegments.count - 1 {
                                    currentIndex += 1
                                }
                            }
                        )
                        .animation(.easeInOut, value: currentIndex)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .navigationBarTitle(Text(article.title.rendered), displayMode: .inline)
    }
}
struct FlashcardView: View {
    var text: String

    var body: some View {
        Text(text)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.vertical, 8)
    }
}
