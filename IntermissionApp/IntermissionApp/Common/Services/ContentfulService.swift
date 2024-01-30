//
//  ContentfulService.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/16/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful
import Alamofire

/// Represents a JSON-parseable model returned by the ContenfulAPI
typealias ContentfulModel = EntryDecodable & FieldKeysQueryable

/// Handles all network requests related to the content of a Post
/// Note: All Contentful models in use must be added to the initializer for proper decoding
final class ContentfulService {
    private let client: Client
    static let shared = ContentfulService()
    
    private init() {
        self.client = Client(spaceId: Keys.Contentful.master.spaceId,
                             environmentId: Keys.Contentful.master.environmentId,
                             accessToken: Keys.Contentful.master.contentDeliveryToken,
                             contentTypeClasses: [Post.self, Author.self, Tag.self,
                                                  Video.self, Series.self, Category.self,
                                                  Retreat.self, RetreatAddon.self,
                                                  FeedPage.self, FeedModule.self, DetailSection.self,
                                                  DashboardRecommendedPosts.self, RetreatPricingOption.self,
                                                  DetailSectionWithGallery.self, RetreatExtendedInfoPage.self])
    }
    
    /// Get a single entry with a specified id (ID must be a contentful-generated UUID)
    static private func getEntry<T: ContentfulModel>(with id: String, completion: @escaping (IAResult<T, ContentError>) -> Void) {
        ContentfulService.shared.client.fetch(T.self, id: id) { (result) in
            switch result {
            case .success(let entry):
                completion(.success(entry))
            case .error(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    /// Get all entries of a particular type
    static func getEntries<T: ContentfulModel>(using query: QueryOn<T>? = nil, completion: @escaping (IAResult<[T], ContentError>) -> Void) {

        let queryOn: QueryOn<T> = {
            guard let q = query else {
                let query = QueryOn<T>().include(10)
                return query
            }
            return q
        }()
        
        ContentfulService.shared.client.fetchArray(of: T.self, matching: queryOn) { (result) in
            switch result {
            case .success(let item):
                completion(.success(item.items))
            case .error(let error):
                completion(.failure(ContentError(error)))
            }
        }

    }
    
    /// Get all entries of a particular type, T, that are referenced by the id of another type, U.
    static private func getEntries<T: ContentfulModel, U: ContentfulModel>(for type: U, completion: @escaping (IAResult<[T], ContentError>) -> Void) {
        let query = QueryOn<T>.where(linksToEntryWithId: type.id)
        ContentfulService.shared.client.fetchArray(of: T.self, matching: query) { (result) in
            switch result {
            case .success(let entries):
                completion(.success(entries.items))
            case .error(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    /// Gets all available posts by a specified Author
    static func getPosts(for author: Author, completion: @escaping (IAResult<[Post], ContentError>) -> Void) {
        ContentfulService.getEntries(for: author) { (result: IAResult<[Post], ContentError>) in
            switch result {
            case .success(let posts):
                completion(.success(posts.removingUnpublished()))
            case .failure(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    /// Gets the associated post for a video. If a video has multiple linked posts, it will only return the first. Though this should be an error since videos are in a 1:1 relationship with posts. 
    static func getPost(for video: Video, completion: @escaping (IAResult<Post, ContentError>) -> Void) {
        ContentfulService.getEntries(for: video) { (result: IAResult<[Post], ContentError>) in
            switch result {
            case .success(let posts):
                let filteredPosts = posts.removingUnpublished()
                
                guard let firstPost = filteredPosts.first else {
                    completion(.failure(ContentError.noResults))
                    return
                }
                completion(.success(firstPost))
                
            case .failure(let error):
                completion(.failure(ContentError(error)))
            }
        }
        
    }
    
    /// Gets the Post associated with a VideoHistoryEntry
    static func getPost(for entry: VideoHistoryEntry, completion: @escaping (IAResult<Post, ContentError>) -> Void) {
        ContentfulService.getEntry(with: entry.postId) { (result: IAResult<Post, ContentError>) in
            switch result {
            case .success(let post):
                guard post.isDisplayable else {
                    completion(.failure(ContentError.noResults))
                    return
                }
                completion(.success(post))
                
            case .failure(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    /// Gets all posts
    static func getPosts(completion: @escaping (IAResult<[Post], ContentError>) -> Void) {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone.autoupdatingCurrent
        let dateComponents = calendar.dateComponents([.month, .day, .year], from: Date())
        let formattedDate = calendar.date(from: dateComponents)
        
        let query = QueryOn<Post>.where(field: .publishDate, .isLessThanOrEqualTo(formattedDate ?? Date()))
        
        ContentfulService.shared.client.fetchArray(of: Post.self, matching: query) { (result) in
            switch result {
            case .success(let response):
                let filteredPosts = response.items.removingUnpublished()
                completion(.success(filteredPosts))
                
            case .error(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    /// Gets all videos
    static func getVideoEntries(completion: @escaping (IAResult<[Video], ContentError>) -> Void) {
        ContentfulService.shared.client.fetchArray(of: Video.self) { (result) in
            switch result {
            case .success(let videos):
                completion(.success(videos.items))
                
            case .error(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    /// Gets all available tags
    static func getAvailableTags(completion: @escaping (IAResult<[Tag], ContentError>) -> Void) {
        ContentfulService.shared.client.fetchArray(of: Tag.self) { (result) in
            switch result {
            case .success(let tags):
                completion(.success(tags.items))
                
            case .error(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    static func getTagsSortedByCategory(completion: @escaping (IAResult<[Category : [Tag]], ContentError>) -> Void) {
        // This query at least will sort the tags alphabetically. Then when I grab the categories, I can iterate through knowing it'll be in order
        let query = try? QueryOn<Tag>.order(by: Ordering("fields.\(Tag.FieldKeys.slug.rawValue)"))
        guard let q = query else { return }
        
        ContentfulService.getEntries(using: q) { (result: IAResult<[Tag], ContentError>) in
            switch result {
            case .success(let tags):
                let categories: Set<Category> = Set(tags.compactMap { $0.category })
                var dict: [Category : [Tag]] = [:]
                categories.forEach { (category) in
                    dict[category] = tags.filter { $0.category?.id == category.id }
                }
                completion(.success(dict))
                
            case .failure(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    /// Gets all posts that contain a specified tag.
    static func getPosts(for tag: Tag, completion: @escaping (IAResult<[Post], ContentError>) -> Void) {
        let query = QueryOn<Post>.where(linksToEntryWithId: tag.id)
        ContentfulService.shared.client.fetchArray(of: Post.self, matching: query) { (result) in
            switch result {
            case .success(let response):
                let filteredPosts = response.items.removingUnpublished()
                completion(.success(filteredPosts))
                
            case .error(let error):
                completion(.failure(ContentError(error)))
            }
        }
    }
    
    /// Gets all Retreats, sorted by Retreat.displayOrder
    static func getRetreats(completion: @escaping (IAResult<[Retreat], ContentError>) -> Void) {
        ContentfulService.getEntries { (result: IAResult<[Retreat], ContentError>) in
            switch result {
            case .success(let retreats):
                completion(.success(retreats.sorted(by: { (a, b) in a.displayOrder < b.displayOrder })))
            case .failure(let error):
                completion(.failure(ContentError.init(error)))
            }
        }
    }
    
}
