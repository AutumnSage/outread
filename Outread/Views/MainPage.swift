import SwiftUI
import Combine

// Assuming Article, BookmarkManager, and ArticleFlashcardView are defined elsewhere

struct MainPageView: View {
    @EnvironmentObject var appData: AppData // Use the shared articles
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var articles = [Article]()
    @State private var featuredArticle: Article? // Placeholder for your logic to set this
    @State private var cancellables = Set<AnyCancellable>()
    @State private var categories = [Category]()
    let backgroundColor = Color(red: 0x11 / 255.0, green: 0x1E / 255.0, blue: 0x2B / 255.0)

    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Set the background color for the entire ZStack, including safe areas
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading) {
                                Text("Home")
                                    .foregroundColor(.white)
                                    .font(.custom("Poppins-Medium", size: 36))
                                    .padding(.top, 8)
                                    .padding(.bottom, -4)
                                     // Apply padding to make text width similar to the rectangle width
                                
                                Rectangle()
                                    .frame(height: 4)
                                    .foregroundColor(Color(red: 150 / 255.0, green: 120 / 255.0, blue: 172 / 255.0))
                                    .padding(.trailing, 230)
                                     // Add some space between the text and the rectangle
                        
                                Text("Featured Read of the Day")
                                                    .font(.custom("Poppins-Medium", size: 20))
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 5) // Adjust padding as needed
                                                
                            }
                            .padding(.horizontal, 15)
                        LazyVStack {
                            
                            // Featured article section
                            if let featured = featuredArticle {
                                featuredArticleSection(featured)
                            }
                            
                            CategoriesScrollView(categories: categories)
                            
                            // Grid for articles
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(articles.dropFirst()) { article in
                                    NavigationLink(destination: ArticleFlashcardView(article: article)) {
                                        ArticleRowContent(article: article)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .navigationTitle("") // Hide the default title
                    .navigationBarHidden(true)
                    .onAppear {
                        loadArticles()
                        loadCategories()
                    }
                }
            }
        }
    // Separate function for featured article view to keep body clean
    @ViewBuilder
    private func featuredArticleSection(_ article: Article) -> some View {
        NavigationLink(destination: ArticleFlashcardView(article: article)) {
            VStack {
                AsyncImage(url: URL(string: article.featuredMedia ?? "")) { phase in
                    switch phase {
                        // Success is dependent on users json format - make sure the jwt token synthesizes a "bool false response"
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure(_), .empty:
                        Image(systemName: "photo").foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 200) // Adjust the height as needed
                .cornerRadius(5)
                .clipped()
                .padding(.horizontal)

                Text(article.title.rendered)
                    .font(.custom("Poppins-Medium", size: 20))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(.top, 5)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 20) // Add some space between the featured article and the grid
    }

    private func loadArticles() {
        NetworkManager.shared.fetchArticles()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error occurred: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { newArticles in
                self.articles = newArticles
                // Find the article titled "Attention is All You Need" and set it as the featured article
                self.featuredArticle = newArticles.first
            })
            .store(in: &self.cancellables)
    }
    
    private func loadCategories() {
        let journalParentID = 59
        NetworkManager.shared.fetchCategories(excludingParentID: journalParentID)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching categories: \(error)")
                }
            }, receiveValue: { [self] fetchedCategories in
                self.categories = fetchedCategories
            })
            .store(in: &cancellables)
    }

}

struct ArticleRowContent: View {
    let article: Article
    @EnvironmentObject var bookmarkManager: BookmarkManager

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: article.featuredMedia ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure(_), .empty:
                    Image(systemName: "photo").foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 150, height: 150)
            .cornerRadius(5)

            Text(article.title.rendered)
                .font(.custom("Poppins-Medium", size: 15))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(height: 50) // Ensure titles take up equal space
            Button(action: {
                                    bookmarkManager.toggleBookmark(for: article)
                                }) {
                                    Image(systemName: bookmarkManager.isArticleBookmarked(article.id) ? "bookmark.fill" : "bookmark")
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(BorderlessButtonStyle())
        }
        // Prevent the entire HStack from acting like a button
        .contentShape(Rectangle())
        .padding()
        }
        
    }

class AppData: ObservableObject {
    @Published var articles: [Article] = []
    // ... other shared data
}
