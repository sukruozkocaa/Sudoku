import SwiftUI

#if DEBUG
struct RemoteConfigDebugPanel: View {
    @Environment(RemoteConfigStore.self) private var remoteConfigStore
    @Environment(\.themePalette) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Remote Config Test")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1.1)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)

            statusCard

            VStack(spacing: 8) {
                debugRow("Fetch", remoteConfigStore.diagnostics.fetchResult.label)
                debugRow("Kaynak", remoteConfigStore.diagnostics.valueSource.label)
                debugRow(
                    "Son fetch",
                    remoteConfigStore.diagnostics.lastFetchDate.map(formattedDate) ?? "—"
                )
                debugRow(
                    "Bundle ile aynı",
                    remoteConfigStore.diagnostics.matchesBundledDefaults ? "Evet" : "Hayır — remote geldi"
                )
            }

            Divider().overlay(theme.cardBorder)

            VStack(spacing: 8) {
                debugRow("hints", remoteConfigStore.config.hintsEnabled ? "true" : "false")
                debugRow("ads.enabled", remoteConfigStore.config.adsEnabled ? "true" : "false")
                debugRow("daily_challenge", remoteConfigStore.config.dailyChallengeEnabled ? "true" : "false")
                debugRow("ad cooldown", "\(Int(remoteConfigStore.config.minimumSecondsBetweenAds))s")
            }

            Button {
                Task {
                    await remoteConfigStore.refresh()
                }
            } label: {
                HStack {
                    if remoteConfigStore.diagnostics.fetchResult == .fetching {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Yeniden Fetch")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.accentGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(remoteConfigStore.diagnostics.fetchResult == .fetching)

            Text("Ham JSON")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary)

            ScrollView {
                Text(prettyJSON(remoteConfigStore.diagnostics.rawJSON))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 160)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )
            )

            Text("Firebase'de bir değer değiştir → Publish → Yeniden Fetch. \"Bundle ile aynı: Hayır\" ve değerlerin güncellenmesi remote config'in geldiğini gösterir.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.accent.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(theme.accent.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var statusCard: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            Text(statusTitle)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(theme.cardBorder, lineWidth: 1)
                )
        )
    }

    private var statusColor: Color {
        switch remoteConfigStore.diagnostics.fetchResult {
        case .fetchedFromRemote, .usedCached:
            .green
        case .fetching:
            .orange
        case .failed:
            .red
        case .idle:
            .gray
        }
    }

    private var statusTitle: String {
        switch remoteConfigStore.diagnostics.fetchResult {
        case .idle:
            "Henüz fetch yapılmadı"
        case .fetching:
            "Fetch devam ediyor..."
        case .fetchedFromRemote:
            "Remote config sunucudan alındı"
        case .usedCached:
            "Önbellekten yüklendi"
        case .failed(let message):
            message
        }
    }

    private func debugRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary)
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .standard)
    }

    private func prettyJSON(_ json: String) -> String {
        guard
            let data = json.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
            let string = String(data: pretty, encoding: .utf8)
        else {
            return json
        }
        return string
    }
}
#endif
