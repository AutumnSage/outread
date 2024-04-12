//
//  ArticleRow.swift
//  Outread
//
//  Created by Dhruv Sirohi on 12/3/2024.
//

import SwiftUI

struct ArticleRow: View {
    let article: Article
    @EnvironmentObject var bookmarkManager: BookmarkManager
    
    var body: some View {
        HStack {
            if let imageUrl = article.featuredMediaUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .cornerRadius(5)
            }
            VStack(alignment: .leading) {
                Text(article.title.rendered).font(.headline)
                Text(article.content.rendered).font(.subheadline).lineLimit(3)
            }
            Spacer()
            // Explicitly define the bookmark button to separate its action
            Button(action: {
                bookmarkManager.toggleBookmark(for: article)
            }) {
                Image(systemName: bookmarkManager.isArticleBookmarked(article.id) ? "bookmark.fill" : "bookmark")
                .foregroundColor(bookmarkManager.isArticleBookmarked(article.id) ? .yellow : .gray)
            }
            .buttonStyle(BorderlessButtonStyle()) // Use BorderlessButtonStyle to avoid any unwanted button styling
        }
        // Prevent the entire HStack from acting like a button
        .contentShape(Rectangle()) // This makes sure the tap area is only the HStack without affecting the button
    }
}
