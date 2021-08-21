//
//  ContentView.swift
//  Shared
//
//  Created by Simon Anderson on 7/01/21.
//

import SwiftUI

struct ContentView: View {
    let vm: ViewModel
    
    init() {
        vm = ViewModel()
    }
    
    // SwiftUI hack to get a press/click that has the screen position where it occured
    var pressWithPos : some Gesture {
        
        return DragGesture(minimumDistance: 0.0, coordinateSpace: .global)
                .onEnded { data in
                    pressTriggered(simd_float2(Float(data.location.x), Float(data.location.y)))
                }
    }
    
    var body: some View {
        SwiftMTKView()
            .gesture(pressWithPos)
    }
    
    func pressTriggered(_ pos:simd_float2) {
        vm.selectionEvent(pos)
    }
}
