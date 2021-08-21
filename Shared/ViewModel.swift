//
//  ViewModel.swift
//  SwiftUI_QuadSelection
//
//  Created by Simon Anderson on 8/08/21.
//

import Foundation

/// ViewModel, should be a more descriptive name, but as this is for learning purposes I have kept it in name with the MVVM naming
/// Model, View, ViewModel

/// View Models have to be a class as they to have a reference pointer
class ViewModel {
    init() {
        
    }
    
    public func selectionEvent(_ pos:simd_float2) {
        print("Selection Event \(pos)")
    }
}
