//
//  HelpRequestStatus.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

enum HelpRequestStatus {
  case InReview
  case WatingForPayment(price: Double)
  case Accepted
  case Rejected
  case Done
}
