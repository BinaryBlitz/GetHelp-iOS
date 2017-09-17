//
//  Post.swift
//  GetHelp
//
//  Created by Алексей on 17.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftDate

class Post: ServerModelPresentable {
  var id: Int = 0
  var title: String = ""
  var subtitle: String = ""
  var content: String = ""
  var imageUrl: String = ""
  var promo: Bool = false
  var createdAt: Date = Date()

  static func createFromJSON(_ json: JSON) -> Post? {
    let post = Post()

    post.id = json["id"].intValue
    post.title = json["title"].stringValue
    post.subtitle = json["subtitle"].stringValue
    post.content = json["content"].stringValue
    post.imageUrl = json["image_url"].stringValue
    post.promo = json["promo"].boolValue

    let dateString = json["created_at"].stringValue

    if let dateCreated = DateInRegion(string: dateString, format: .iso8601(options: .withInternetDateTimeExtended))?.absoluteDate {
      post.createdAt = dateCreated
    }

    return post
  }

  func convertToDict() -> [String : Any] {
    return [:]
  }
}
