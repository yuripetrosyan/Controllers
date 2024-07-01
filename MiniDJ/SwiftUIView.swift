//
//  SwiftUIView.swift
//  MiniDJ
//
//  Created by Yuri Petrosyan on 17/06/2024.
//

import SwiftUI

struct SwiftUIView: View {
    
    @State var outerRadius: Double = 2
    var innerRadius: Double = 2
   
    var body: some View {
        ZStack{
           
            VStack{

                
                ZStack{
                    
                    HStack{
                    Slider(value: $outerRadius, in: 0...100)
                        .tint(.yellow)
                        .frame(width: 200)
                        .padding(40)
                    
                    Spacer()
                }
                    
                    ZStack{
                        
                        HStack{
                            
                            RoundedRectangle(cornerRadius: 30)
                                .frame(width: 2*outerRadius, height: 80)
                                .foregroundStyle(.ultraThinMaterial)
                                .padding()
                               
                            
                            
                            
                            
                            Spacer()
                        }
                        
                        HStack{
                            
                            Image(systemName: "speaker")
                                .font(.title)
                                .foregroundStyle(.yellow)
                                .rotationEffect(.degrees(90))
                                .padding(40)
                            
                            Spacer()
                        }
                    }
                    
                   

                }.rotationEffect(.degrees(270))
            }
        }
        
    }
}

#Preview {
    SwiftUIView()
}
