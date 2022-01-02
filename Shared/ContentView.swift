//
//  ContentView.swift
//  Shared
//
//  Created by Simon Anderson on 7/01/21.
//

import SwiftUI

struct ContentView: View {
    let vm: ViewModel
    
    // Global space is used for OSX, while iOS uses local, as iOS has more screen space that is used by the sytem.
    // Decided to go with local space for both, as the view encompasses the entire apps realestate.
    #if os(OSX)
    let coordinateSpace = CoordinateSpace.local
    #elseif os(iOS)
    let coordinateSpace = CoordinateSpace.local
    #endif
    
    
    init() {
        vm = ViewModel()
    }
 
    // MARK:- GESTURES
    
    // SwiftUI hack to get a press/click that has the screen position where it occured
    var pressWithPos : some Gesture {
        
        return DragGesture(minimumDistance: 0.0, coordinateSpace: coordinateSpace)
                .onEnded { data in
                    vm.pressTriggered(simd_int2(Int32(data.location.x), Int32(data.location.y)))
                }
    }
    
    // MARK:- UI VIEWS
    
    var body: some View {
        SwiftMTKView(_viewModel: vm)
            .gesture(pressWithPos)
    }
}
