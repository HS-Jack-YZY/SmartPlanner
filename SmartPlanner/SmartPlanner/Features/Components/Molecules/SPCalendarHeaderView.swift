import SwiftUI

struct SPCalendarHeaderView: View {
    // MARK: - Properties
    
    let currentDate: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏
            HStack {
                // 返回按钮（显示年份）
                Button(action: {}) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.red)
                        Text(DateHelper.yearTitle(for: currentDate))
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // 月份标题
                Text(DateHelper.monthTitle(for: currentDate))
                    .font(.system(size: 34, weight: .bold))
                
                Spacer()
                
                // 工具按钮
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // 星期标题
            HStack(spacing: 0) {
                ForEach(DateHelper.weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            
            // 分隔线
            Divider()
        }
    }
}

// MARK: - Preview

struct SPCalendarHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SPCalendarHeaderView(
            currentDate: Date(),
            onPreviousMonth: {},
            onNextMonth: {}
        )
        .previewLayout(.sizeThatFits)
    }
} 