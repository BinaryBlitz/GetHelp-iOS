//
//  ServerError.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 05/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

enum ServerError: Error {
  case unauthorized
  case internalServerError
  case unspecifiedError
  case invalidData
}
