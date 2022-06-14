import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        
        NavigationView {
            ScrollView {
                PieSliceView(pieSliceData: PieSliceData(startAngle: .degrees(0.0), endAngle: .degrees(200), text: "Missed days", color: .blue))
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



