//
//  ServerError.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 05/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

enum ServerError: ErrorType {
  case Unauthorized
  case InternalServerError
  case UnspecifiedError
  case InvalidData
}
