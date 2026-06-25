import Foundation

enum L10n {
    static var appName: String { String(localized: "app_name") }
    static var homeTagline: String { String(localized: "home_tagline") }
    static var continueGame: String { String(localized: "continue_game") }
    static var newGame: String { String(localized: "new_game") }
    static var start: String { String(localized: "start") }
    static var splashTagline: String { String(localized: "splash_tagline") }
    static var selectDifficulty: String { String(localized: "select_difficulty") }
    static var difficultyProgressNote: String { String(localized: "difficulty_progress_note") }
    static var hint: String { String(localized: "hint") }
    static var delete: String { String(localized: "delete") }
    static var undo: String { String(localized: "undo") }
    static var congratulations: String { String(localized: "congratulations") }
    static var nextLevel: String { String(localized: "next_level") }
    static var home: String { String(localized: "home") }
    static var allCellsFilled: String { String(localized: "all_cells_filled") }
    static var hintPopupTitle: String { String(localized: "hint_popup_title") }
    static var hintSuggestedNumber: String { String(localized: "hint_suggested_number") }
    static var hintApply: String { String(localized: "hint_apply") }
    static var hintCancel: String { String(localized: "hint_cancel") }
    static var hintNoNumbers: String { String(localized: "hint_no_numbers") }

    static func hintExplanationRowOnly(value: Int, row: Int) -> String {
        String(format: String(localized: "hint_explanation_row_only"), row, value)
    }

    static func hintExplanationColumnOnly(value: Int, column: Int) -> String {
        String(format: String(localized: "hint_explanation_column_only"), column, value)
    }

    static func hintExplanationBoxOnly(value: Int, boxHeight: Int, boxWidth: Int) -> String {
        String(format: String(localized: "hint_explanation_box_only"), boxHeight, boxWidth, value)
    }

    static func hintExplanationElimination(
        value: Int,
        rowNumbers: String,
        columnNumbers: String,
        boxNumbers: String
    ) -> String {
        String(
            format: String(localized: "hint_explanation_elimination"),
            value,
            rowNumbers,
            columnNumbers,
            boxNumbers
        )
    }

    static func hintExplanationFallback(value: Int) -> String {
        String(format: String(localized: "hint_explanation_fallback"), value)
    }

    static var difficultyEasy: String { String(localized: "difficulty_easy") }
    static var difficultyMedium: String { String(localized: "difficulty_medium") }
    static var difficultyHard: String { String(localized: "difficulty_hard") }
    static var difficultyEasySubtitle: String { String(localized: "difficulty_easy_subtitle") }
    static var difficultyMediumSubtitle: String { String(localized: "difficulty_medium_subtitle") }
    static var difficultyHardSubtitle: String { String(localized: "difficulty_hard_subtitle") }

    static func level(_ level: Int) -> String {
        String(format: String(localized: "level_format"), level)
    }

    static func savedProgress(level: Int, difficulty: String) -> String {
        String(format: String(localized: "saved_progress_format"), level, difficulty)
    }

    static func levelCompleted(_ level: Int) -> String {
        String(format: String(localized: "level_completed_format"), level)
    }

    static var howToPlayTitle: String { String(localized: "how_to_play_title") }
    static var settingsTitle: String { String(localized: "settings_title") }
    static var settingsAppearanceNote: String { String(localized: "settings_appearance_note") }
    static var settingsRateApp: String { String(localized: "settings_rate_app") }
    static var settingsRateAppSubtitle: String { String(localized: "settings_rate_app_subtitle") }
    static var settingsFeedbackNote: String { String(localized: "settings_feedback_note") }
    static var settingsHaptics: String { String(localized: "settings_haptics") }
    static var settingsHapticsSubtitle: String { String(localized: "settings_haptics_subtitle") }
    static var settingsSounds: String { String(localized: "settings_sounds") }
    static var settingsSoundsSubtitle: String { String(localized: "settings_sounds_subtitle") }
    static var appearanceSystem: String { String(localized: "appearance_system") }
    static var appearanceLight: String { String(localized: "appearance_light") }
    static var appearanceDark: String { String(localized: "appearance_dark") }
    static var appearanceSystemSubtitle: String { String(localized: "appearance_system_subtitle") }
    static var appearanceLightSubtitle: String { String(localized: "appearance_light_subtitle") }
    static var appearanceDarkSubtitle: String { String(localized: "appearance_dark_subtitle") }
    static var howToPlaySkip: String { String(localized: "how_to_play_skip") }
    static var howToPlayNext: String { String(localized: "how_to_play_next") }
    static var howToPlayBack: String { String(localized: "how_to_play_back") }
    static var howToPlayFinish: String { String(localized: "how_to_play_finish") }
    static var howToPlayStep1Title: String { String(localized: "how_to_play_step1_title") }
    static var howToPlayStep1Body: String { String(localized: "how_to_play_step1_body") }
    static var howToPlayStep2Title: String { String(localized: "how_to_play_step2_title") }
    static var howToPlayStep2Body: String { String(localized: "how_to_play_step2_body") }
    static var howToPlayStep3Title: String { String(localized: "how_to_play_step3_title") }
    static var howToPlayStep3Body: String { String(localized: "how_to_play_step3_body") }
    static var howToPlayStep4Title: String { String(localized: "how_to_play_step4_title") }
    static var howToPlayStep4Body: String { String(localized: "how_to_play_step4_body") }
    static var howToPlayStep5Title: String { String(localized: "how_to_play_step5_title") }
    static var howToPlayStep5Body: String { String(localized: "how_to_play_step5_body") }

    static func howToPlayStepProgress(current: Int, total: Int) -> String {
        String(format: String(localized: "how_to_play_step_progress"), current, total)
    }
}
