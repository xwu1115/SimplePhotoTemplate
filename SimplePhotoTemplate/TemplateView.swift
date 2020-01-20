//
//  TemplateView.swift
//  PhotoEditKit
//
//  Created by Shawn Wu on 1/11/20.
//  Copyright © 2020 Shawn Wu. All rights reserved.
//

import UIKit
import SnapKit

public class TemplateView: UIView {
    private let template: Template
    private let backgroundView: UIImageView = UIImageView()
    private let maxWidthOrHeight: CGFloat = 1980
    
    private var previousPoint: CGPoint?
    private var previousSize: CGSize = .zero
    private var textViews: [TemplateTextView] = []
    private var photoViews: [UIImageView] = []
    
    public init(template: Template) {
        self.template = template
        super.init(frame: .null)
        
        setUp()
    }
    
    private func setUp() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hanldeTapGesture(_:)))
        backgroundView.image = UIImage(named: template.background)
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.addGestureRecognizer(tapGesture)
        backgroundView.isUserInteractionEnabled = true
        addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for text in template.texts {
            add(textField: TemplateTextView(text: text))
        }

        clipsToBounds = true
    }
    
    @objc private func hanldeTapGesture(_ recoginzer: UITapGestureRecognizer) {
        textViews.forEach { _ = $0.resignFirstResponder() }
    }
    
    @objc private func hanldePanGesture(_ recoginzer: UIPanGestureRecognizer) {
        switch recoginzer.state {
        case .began:
            previousPoint = recoginzer.translation(in: self)
        case .changed:
            let dx = recoginzer.translation(in: self).x - (previousPoint?.x ?? 0)
            let dy = recoginzer.translation(in: self).y - (previousPoint?.y ?? 0)
            recoginzer.view?.frame = CGRect(x: (recoginzer.view?.frame.origin.x ?? 0) + dx,
                                            y: (recoginzer.view?.frame.origin.y ?? 0) + dy,
                                            width: recoginzer.view?.frame.width ?? 0,
                                            height: recoginzer.view?.frame.height ?? 0)
            previousPoint = recoginzer.translation(in: self)
        case .ended:
            previousPoint = nil
        default:
            break
        }
    }
    
    @objc private func hanldePinchGesture(_ recoginzer: UIPinchGestureRecognizer) {
        if recoginzer.state == .began || recoginzer.state == .changed {
            recoginzer.view?.transform = (recoginzer.view?.transform.scaledBy(x: recoginzer.scale,
                                                                              y: recoginzer.scale))!
            recoginzer.scale = 1.0
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard previousSize != frame.size else { return }
        
        // adjust frames here
        previousSize = frame.size
    
        for textView in textViews {
            let size = textView.sizeThatFits(CGSize(width: TemplateTextView.maxWidth, height: 44))
            textView.frame = CGRect(x: frame.width * 0.5,
                                    y: frame.width * 0.5,
                                    width: size.width,
                                    height: size.height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func add(text: Text) {
        let textField = TemplateTextView(text: text)
        let size = textField.sizeThatFits(CGSize(width: TemplateTextView.maxWidth, height: 44))
        textField.frame = CGRect(x: frame.width * 0.5,
                                 y: frame.height * 0.5,
                                 width: size.width,
                                 height:size.height)
        add(textField: textField)
    }
    
    public func updateBackground(image: UIImage) {
        backgroundView.image = image.squared
    }
    
    public func add(image: UIImage) {
        let downsampledImage = image.downsample(maxWidthOrHeight: 1080)
        let newPhotoView = UIImageView(image: downsampledImage)
        newPhotoView.contentMode = .scaleAspectFit
        newPhotoView.frame = CGRect(x: frame.width * 0.5,
                                    y: frame.height * 0.5,
                                    width: downsampledImage.size.width * 0.5,
                                    height: downsampledImage.size.height * 0.5)
        if let last = photoViews.last {
            insertSubview(newPhotoView, aboveSubview: last)
        } else {
            insertSubview(newPhotoView, aboveSubview: backgroundView)
        }
        photoViews.append(newPhotoView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hanldePanGesture(_:)))
        newPhotoView.addGestureRecognizer(panGesture)
        newPhotoView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(hanldePinchGesture(_:)))
        newPhotoView.addGestureRecognizer(pinchGesture)
    }
    
    public func render() -> UIImage {
        if let raw = backgroundView.image {
            let backgroundImage = raw.downsample(maxWidthOrHeight: maxWidthOrHeight)
            let renderer = UIGraphicsImageRenderer(size: backgroundImage.size)
            return renderer.image { _ in
                backgroundImage.draw(at: .zero)
                
                for photoView in photoViews {
                    if let photo = photoView.image {
                        let newFrame = calculateNewFrame(current: photoView.frame,
                                                         currentBackground: backgroundView.frame.size,
                                                         newBackground: backgroundImage.size)
                        photo.draw(in: newFrame)
                    }
                }
                
                for text in textViews {
                    let textFieldFrame = computeTextFieldFrame(orginalFrame: text.frame)
                    let newFrame = calculateNewFrame(current: textFieldFrame,
                                                     currentBackground: backgroundView.frame.size,
                                                     newBackground: backgroundImage.size)
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .left
                    
                    let ratio = backgroundImage.size.width / backgroundView.frame.size.width
                    let attrs = [NSAttributedString.Key.font: UIFont(name: text.textField.font!.fontName,
                                                                     size: text.textField.font!.pointSize * ratio)!,
                                 NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                 NSAttributedString.Key.foregroundColor: text.textField.textColor ?? UIColor.black]
                    
                    let string = NSAttributedString(string: text.textField.text, attributes: attrs)
                    string.draw(in: newFrame)
                }
            }
        } else {
            return UIImage()
        }
    }
    
    private func calculateNewFrame(current: CGRect, currentBackground: CGSize, newBackground: CGSize) -> CGRect {
        let x = (current.origin.x / currentBackground.width) * newBackground.width
        let y = (current.origin.y / currentBackground.height) * newBackground.height
        let width = (current.width / currentBackground.width) * newBackground.width
        let height = (current.height / currentBackground.height) * newBackground.width
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func add(textField: TemplateTextView) {
        textField.delegate = self
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hanldePanGesture(_:)))
        textField.addGestureRecognizer(panGesture)
        addSubview(textField)
        textViews.append(textField)
    }
    
    private func downsample(for image: UIImage, maxWidthOrHeight: CGFloat) -> UIImage {
        let size = image.size
        let newWidth: CGFloat
        let newHeight: CGFloat
        if size.width >= size.height {
            newWidth = maxWidthOrHeight
            newHeight = (size.height * newWidth) / size.width
        } else {
            newHeight = maxWidthOrHeight
            newWidth = (size.width * newHeight) / size.height
        }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: newHeight))
        return renderer.image { context in
            image.draw(in: context.format.bounds)
        }
    }
    
    private func computeTextFieldFrame(orginalFrame: CGRect) -> CGRect {
        return CGRect(x: orginalFrame.origin.x,
                      y: orginalFrame.origin.y + TemplateTextView.buttonWidth,
                      width: orginalFrame.width - TemplateTextView.buttonWidth,
                      height: orginalFrame.height - TemplateTextView.buttonWidth)
    }
}

extension TemplateView: TemplateTextViewDelegate {
    func deleteButtonWasTapped(textField: TemplateTextView) {
        if let index = textViews.firstIndex(of: textField) {
            textViews.remove(at: index)
        }
        textField.removeFromSuperview()
    }
    
    func contentSizeChanged(size: CGSize, textView: TemplateTextView) {
        guard textView.frame.size != size else { return }
        
        textView.frame = CGRect(x: textView.frame.origin.x,
                                y: textView.frame.origin.y,
                                width: size.width,
                                height: size.height)
    }
}
