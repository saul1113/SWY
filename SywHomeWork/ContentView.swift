//
//  ContentView.swift
//  SywHomeWork
//
//  Created by 강희창 on 1/20/25.
//

import SwiftUI

struct ContentView: View {
    @State private var japan: Bool = false
    var body: some View {
        VStack {
            Button(action: {
                japan.toggle()
            }) {
                Text("일본")
                    .font(.title)
                    .frame(width: 100, height: 70)
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .cornerRadius(20)
            }
            if japan {
                Text("나도 오키나와 가고싶다🇯🇵")
                    .font(.system(size: 30))
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
