//
//  TemplateTextView.swift
//  SimplePhotoTemplate
//
//  Created by Shawn Wu on 1/19/20.
//  Copyright © 2020 Shawn Wu. All rights reserved.
//

import UIKit
import SnapKit

protocol TemplateTextViewDelegate: AnyObject {
    func deleteButtonWasTapped(textField: TemplateTextView)
    func contentSizeChanged(size: CGSize, textView: TemplateTextView)
}

class TemplateTextView: UIView, UITextViewDelegate {
    static let buttonWidth: CGFloat = 20
    static let maxWidth: CGFloat = 180
    weak var delegate: TemplateTextViewDelegate?
    let deleteButton: UIButton
    let textField: UITextView
    
    init(text: Text) {
        textField = UITextView(frame: .null)
        deleteButton = UIButton()
        
        super.init(frame: .null)
        textField.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textField.textContainer.lineFragmentPadding = 0
        textField.backgroundColor = .clear
        textField.isScrollEnabled = false
        textField.text = "Text"
        textField.font = UIFont(name: text.font, size: CGFloat(text.size))
        textField.textColor = .black
        addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(TemplateTextView.buttonWidth)
            make.left.bottom.equalToSuperview().priority(999)
        }
        
        let currentBundle = Bundle(for: type(of: self))
        let dismissImage = UIImage(named: "dismiss", in: currentBundle, compatibleWith: nil)
        deleteButton.setBackgroundImage(dismissImage?.withRenderingMode(.alwaysTemplate),
                                        for: .normal)
        deleteButton.tintColor = .black
        addSubview(deleteButton)
        deleteButton.addTarget(self,
                               action: #selector(hanldeDeleteButtonTapped(_:)),
                               for: .touchUpInside)
        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(TemplateTextView.buttonWidth)
            make.top.right.equalToSuperview()
        }
        
        deleteButton.isHidden = true
        textField.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = textField.sizeThatFits(CGSize(width: TemplateTextView.maxWidth,
                                                 height: CGFloat.leastNormalMagnitude))
        // compute the new text size with the delete button included
        return CGSize(width: size.width + TemplateTextView.buttonWidth,
                      height: size.height + TemplateTextView.buttonWidth)
    }
    
    override func resignFirstResponder() -> Bool {
        deleteButton.isHidden = true
        return textField.resignFirstResponder()
    }
    
    @objc func hanldeDeleteButtonTapped(_ view: UIButton) {
        delegate?.deleteButtonWasTapped(textField: self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        deleteButton.isHidden = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let extendedSize = sizeThatFits(CGSize(width: TemplateTextView.maxWidth,
                                               height: CGFloat.leastNormalMagnitude))
        delegate?.contentSizeChanged(size: extendedSize, textView: self)
    }
}
