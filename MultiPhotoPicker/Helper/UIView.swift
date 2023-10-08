//
//  UIView.swift
//  MultiPhotoPicker
//
//  Created by YuthFight's MacBook Pro  on 8/10/23.
//

import UIKit

extension UIView {
   
   func didTap(completion: @escaping Completion) {
       let tap = CompletionGesture(target: self, action: #selector(didTapCallback(_:)))
       tap.completion = completion
       
       self.isUserInteractionEnabled = true
       addGestureRecognizer(tap)
   }
   
   @objc fileprivate func didTapCallback(_ sender: CompletionGesture) {
       sender.completion()
   }
   
   // ----------------------------------------------------------------------
   func addTapGesture(target: Any?, selector: Selector) {
       self.isUserInteractionEnabled = true
       self.addGestureRecognizer(
           UITapGestureRecognizer(target: target, action: selector)
       )
   }
   
   func addPanGesture(target: Any?, selector: Selector) {
       self.isUserInteractionEnabled = true
       self.addGestureRecognizer(
           UIPanGestureRecognizer(target: target, action: selector)
       )
   }
}

class CompletionGesture: UITapGestureRecognizer {
   var completion = { }
}
