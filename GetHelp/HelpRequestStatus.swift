//
//  HelpRequestStatus.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

enum HelpRequestStatus: String {
  case InReview = "new"
  case WaitingForPayment = "pending"
  case Accepted = "paid"
  case Rejected = "rejected"
}
