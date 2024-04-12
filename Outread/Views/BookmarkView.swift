//
//  BookmarkView.swift
//  Outread
//
//  Created by Dhruv Sirohi on 2/4/2024.
//

import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var bookmarkManager: BookmarkManager

    var body: some View {
        List(bookmarkManager.bookmarkedArticles, id: \.id) { article in
            ArticleRow(article: article)
        }
        .navigationTitle("Bookmarks")
    }
}
