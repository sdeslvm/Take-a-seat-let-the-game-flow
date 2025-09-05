import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol TakeProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol TakeBackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct TakeLoadingOverlay: View, TakeProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Однородный фон с цветом #10928E
                Color(hex: "#10928E")
                    .ignoresSafeArea()

                VStack(spacing: 36) {
                    Spacer()
                    // Название приложения с анимацией
                    Text("Take a Seat")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "#10928E").opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.18), radius: 8, y: 4)
                        .scaleEffect(pulse ? 1.04 : 0.98)
                        .animation(
                            Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }

                    // Прогрессбар и проценты
                    VStack(spacing: 18) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        TakeProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.54, height: 12)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.10))
                            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                    )
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct TakeBackground: View, TakeBackgroundProviding {
    func makeBackground() -> some View {
        Color(hex: "#10928E")
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct TakeProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var particles: [TakeProgressParticle] = []

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
                .onAppear {
                    startShimmerAnimation()
                    startPulseAnimation()
                    generateParticles(width: geometry.size.width)
                }
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
            particleOverlay(in: geometry)
        }
    }

    private func backgroundTrack(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color.white.opacity(0.18))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        Color.white.opacity(0.25),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.18), radius: 6, y: 2)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Основной прогрессбар с оттенками #10928E
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#10928E"),
                            Color(hex: "#13BBAF"),
                            Color(hex: "#10928E")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .scaleEffect(pulseScale)
                .shadow(color: Color(hex: "#10928E").opacity(0.5), radius: 10, y: 0)
                .shadow(color: Color(hex: "#13BBAF").opacity(0.3), radius: 14, y: 0)

            // Анимированный блеск
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.7),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * 0.3, height: height)
                .offset(x: shimmerOffset * width)
                .clipped()
                .frame(width: width, height: height)

            // Внутреннее свечение
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.clear,
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: height / 2
                    )
                )
                .frame(width: width, height: height * 0.6)
        }
        .animation(.easeInOut(duration: 0.3), value: value)
    }

    private func particleOverlay(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width

        return ZStack {
            ForEach(particles.indices, id: \.self) { index in
                if particles[index].x <= width {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#13BBAF").opacity(0.7),
                                    Color.clear,
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 2
                            )
                        )
                        .frame(width: 4, height: 4)
                        .position(x: particles[index].x, y: particles[index].y)
                        .opacity(particles[index].opacity)
                }
            }
        }
    }

    private func startShimmerAnimation() {
        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.2
        }
    }

    private func startPulseAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
    }

    private func generateParticles(width: CGFloat) {
        particles = (0..<12).map { _ in
            TakeProgressParticle(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 2...8),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
}

private struct TakeProgressParticle {
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

// MARK: - Превью

#Preview("Vertical") {
    TakeLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    TakeLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
