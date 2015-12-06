//
//  IndicatorView.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

enum IndicatorViewType {
  case Left
  case Right
}

class IndicatorView: UIView {
  
  var type: IndicatorViewType = .Left
  
  override func layoutSubviews() {
    
    let corners: UIRectCorner
    
    switch type {
    case .Right:
      corners = [.BottomRight, .TopRight]
    case .Left:
      corners = [.BottomLeft, .TopLeft]
    }
    
    let path = UIBezierPath(
      roundedRect: bounds,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: 10, height: 10)
    )
    let maskLayer = CAShapeLayer()
    maskLayer.path = path.CGPath
    layer.mask = maskLayer
  }
}