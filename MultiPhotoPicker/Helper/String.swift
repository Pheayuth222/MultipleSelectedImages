//
//  String.swift
//  MultiPhotoPicker
//
//  Created by YuthFight's MacBook Pro  on 8/10/23.
//

import UIKit

extension String {
    
}

func convertToBase64(_ image: UIImage) -> String! {
    return image.jpegData(compressionQuality: 0.5)?.base64EncodedString(options: .endLineWithLineFeed)
}
