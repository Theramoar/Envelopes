import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        
        NavigationView {
            ScrollView {
                PieSliceView(pieSliceData: PieSliceData(startAngle: .degrees(0.0), endAngle: .degrees(200), color: .blue))
            }
                .navigationTitle("Analytics")
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}


struct PieSliceView: View {
    var pieSliceData: PieSliceData
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width: CGFloat = min(geometry.size.width, geometry.size.height)
                let height = width
                
                let center = CGPoint(x: width * 0.5, y: height * 0.5)
                
                path.move(to: center)
                
                path.addArc(
                    center: center,
                    radius: width * 0.5,
                    startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle,
                    endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                    clockwise: false)
                
            }
            .fill(pieSliceData.color)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
}
