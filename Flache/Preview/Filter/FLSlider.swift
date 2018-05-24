//
//  FLSlider.swift
//  Flache
//
//  Created by Patrick Bellot on 5/24/18.
//  Copyright © 2018 Polestar Interactive LLC. All rights reserved.
//

import UIKit

open class FLSlider: UIView {
	
	fileprivate var slider: UIScrollView
	fileprivate var numberOfPages: Int
	fileprivate var startingIndex: Int
	fileprivate var data = [FLFilter]()
	fileprivate let slideAxis: SlideAxis
	
	open weak var dataSource: FLSliderDataSource?
	
	public init(frame: CGRect, slideAxis: SlideAxis = .horizontal) {
		self.slideAxis = slideAxis
		numberOfPages = 3
		startingIndex = 0
		slider = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
		
		super.init(frame: frame)
		
		self.slider.delegate = self
		self.slider.isPagingEnabled = true
		self.slider.bounces = false
		self.slider.showsHorizontalScrollIndicator = false
		self.slider.layer.zPosition = 1
		self.add(self.slider)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func reloadData() {
		self.cleanData()
		self.loadData()
		self.presentData()
	}
	
	open func slideShown() -> FLFilter {
		let index = slideAxis.index(with: slider)
		return data[Int(index)]
	}
	
	fileprivate func cleanData() {
		for v in subviews {
			let filter = v as? FLFilter
			if filter != nil {
				v.removeFromSuperview()
			}
		}
		data.removeAll()
	}
	
	fileprivate func loadData() {
		
		self.numberOfPages = dataSource!.numberOfSlides(self)
		self.startingIndex = dataSource!.startAtIndex(self)
		self.slider.contentSize = slideAxis.contentSize(with: self)
		
		var filter = dataSource!.slider(self, slideAtIndex:self.numberOfPages-1).copy() as! FLFilter
		data.append(filter)
		
		for i in 0..<self.numberOfPages {
			let filter = dataSource!.slider(self, slideAtIndex:i).copy() as! FLFilter
			data.append(filter)
		}
		
		filter = dataSource!.slider(self, slideAtIndex:0).copy() as! FLFilter
		data.append(filter)
		
		self.slider.scrollRectToVisible(slideAxis.rect(at: startingIndex, in: self),
																		animated:false);
	}
	
	fileprivate func presentData() {
		
		for i in 0..<data.count {
			weak var filter: FLFilter! = data[i]
			filter.layer.zPosition = 0
			filter.mask(filter.frame)
			switch slideAxis {
			case .horizontal:
				filter.updateMask(filter.frame, newXPosition: slideAxis.positionOfPage(at: (i - startingIndex - 2), in: self))
			}
			self.add(filter)
		}
	}
}

// MARK: - Scroll View Delegate

extension FLSlider: UIScrollViewDelegate {
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		for i in 0..<data.count {
			switch slideAxis {
			case .horizontal:
				data[i].updateMask(data[i].frame, newXPosition: slideAxis.positionOfPage(at: i - 1, in: self) - scrollView.contentOffset.x)
			}
		}
	}
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		switch slideAxis {
		case .horizontal:
			if (scrollView.contentOffset.x == slideAxis.positionOfPage(at: -1, in: self)) {
				self.slider.scrollRectToVisible(slideAxis.rect(at: numberOfPages - 1, in: self),
																				animated:false);
			}
			else if (scrollView.contentOffset.x == slideAxis.positionOfPage(at: numberOfPages, in: self)) {
				self.slider.scrollRectToVisible(slideAxis.rect(at: 0, in: self),
																				animated:false);
			}
		}
	}
}

extension FLSlider {
	public enum SlideAxis {
		case horizontal
		
		func contentSize(with slider: FLSlider) -> CGSize {
			switch self {
			case .horizontal:
				return CGSize(width: slider.frame.width * (CGFloat(slider.numberOfPages + 2)), height: slider.frame.height)
			}
		}
		
		func index(with slider: UIScrollView) -> Int {
			switch self {
			case .horizontal:
				return Int(slider.contentOffset.x / slider.frame.size.width)
			}
		}
		
		func rect(at index: Int, in slider: FLSlider) -> CGRect {
			switch self {
			case .horizontal:
				return CGRect(x: positionOfPage(at: index, in: slider), y: 0.0, width: slider.frame.width, height: slider.frame.height)
			}
		}
		
		func positionOfPage(at index: Int, in slider: FLSlider) -> CGFloat {
			switch self {
			case .horizontal:
				return slider.frame.size.width * CGFloat(index) + slider.frame.size.width
			}
		}
	}
}
