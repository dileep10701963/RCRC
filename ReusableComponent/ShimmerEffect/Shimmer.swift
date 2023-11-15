//
//  Shimmer.swift
//  RCRC
//
//  Created by Errol on 16/09/20.
//

import Foundation
import UIKit

@objc
public class Shimmer: NSObject {

  public static let settings = ShimmerSettings()

    private static let layerName = Constants.shimmerLayerName

  @objc
  public class func start(for view: UIView, except views: [UIView] = [], isToLastView: Bool = false) {

    guard view.subviews.count != 0 else {
      startFor(view)
      return
    }

    guard !isToLastView else {
      search(view: view, except: views, isToLastView: isToLastView)
      return
    }

    view.subviews.forEach { if !views.contains($0) { startFor($0) } }

  }

  @objc
  public class func start(for tableView: UITableView) {
    tableView.visibleCells.forEach { search(view: $0) }
    tableView.isUserInteractionEnabled = false
  }

  private class func search(view: UIView, except views: [UIView] = [], isToLastView: Bool = false) {

    guard !views.contains(view) else {
      return
    }

    if view.subviews.count > 0 {
      view.subviews.forEach {   search(view: $0, except: views, isToLastView: isToLastView)}
    } else {
      start(for: view)
    }
  }

  @objc
  public class func stop(for view: UIView) {

    guard view.subviews.count != 0 else {
      removeShimmerLayer(for: view)
      return
    }

    if let tableView = view as? UITableView {
      tableView.isUserInteractionEnabled = true
    }

    view.subviews.forEach { subview in
      if subview is UIControl {
        removeShimmerLayer(for: subview)
      } else if subview.subviews.count > 0 {
        subview.subviews.forEach { stop(for: $0) }
      } else {
        removeShimmerLayer(for: subview)
      }
    }
  }

  private class func removeShimmerLayer(for view: UIView) {

    view.layer.sublayers?.forEach {
      if $0.name == layerName {
        $0.removeFromSuperlayer()
      }
    }
  }

  private class func startFor(_ view: UIView) {

    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.locations = [0.0, 0.1, 0.3]
    gradientLayer.colors = [settings.lightColor, settings.darkColor, settings.lightColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    gradientLayer.name = layerName
    view.layer.addSublayer(gradientLayer)

    animate(layer: gradientLayer)
  }

  private class func animate(layer: CAGradientLayer) {

    let animation = CABasicAnimation(keyPath: Constants.shimmerKeyPath)
    animation.duration = settings.duration
    animation.toValue = [0.6, 1.2, 1.5]
    animation.isRemovedOnCompletion = false
    animation.repeatCount = settings.repeatCount
    layer.add(animation, forKey: Constants.shimmerKey)
  }

}

public class ShimmerSettings {
    public var duration = 2.0
    public var darkColor = UIColor(white: 0.85, alpha: 1.0).cgColor
    public var lightColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    public var repeatCount = HUGE
}
