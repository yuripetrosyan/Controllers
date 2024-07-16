//
//  Logo .swift
//  Controllers
//
//  Created by Yuri Petrosyan on 05/07/2024.
//

import SwiftUI
import Pow

struct Logo: View {
    @State var isAdded = false
    @State var count = 300

    var body: some View {
        
        ZStack{
            Color.clear
            
            if isAdded {
                Circle()
                    .frame(width: 300, height: 300)
                    .shadow(color: .red, radius: 60)
                    .foregroundStyle(RadialGradient(gradient: Gradient(colors: [Color.orange, Color.red]), center: .center, startRadius: 30, endRadius: 80))
                    .conditionalEffect(.pushDown, condition: isAdded)
                    .transition(
                        .movingParts.boing
                    )
            }
        }   .contentShape(Circle())
            .onTapGesture {
              withAnimation {
                isAdded.toggle()
              }
            }
        
    }
}

#Preview {
    Logo()
}
