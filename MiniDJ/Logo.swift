//
//  Logo .swift
//  Controllers
//
//  Created by Yuri Petrosyan on 05/07/2024.
//

import SwiftUI

struct Logo: View {
    var body: some View {
        
        Circle()
            .frame(width: 300, height: 300)
            .shadow(color: .red, radius: 60)
            .foregroundStyle(RadialGradient(gradient: Gradient(colors: [Color.orange, Color.red]), center: .center, startRadius: 30, endRadius: 80))
           
               
            
        
    }
}

#Preview {
    Logo()
}
