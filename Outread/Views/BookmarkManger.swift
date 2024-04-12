import Combine

class BookmarkManager: ObservableObject {
    @Published var bookmarkedArticles: [Article] = []
    
    func isArticleBookmarked(_ id: Int) -> Bool {
        bookmarkedArticles.contains(where: { $0.id == id })
    }
    
    func toggleBookmark(for article: Article) {
        if let index = bookmarkedArticles.firstIndex(where: { $0.id == article.id }) {
            bookmarkedArticles.remove(at: index)
        } else {
            bookmarkedArticles.append(article)
        }
    }
}
