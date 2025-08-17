$filesToUpdate = @(
    "lib\zenster_bms\ui_view\battery_tips_view.dart",
    "lib\zenster_bms\ui_view\battery_health_view.dart",
    "lib\zenster_bms\ui_view\charging_view.dart",
    "lib\zenster_bms\ui_view\workout_view.dart",
    "lib\zenster_bms\ui_view\wave_view.dart",
    "lib\zenster_bms\ui_view\mediterranean_diet_view.dart",
    "lib\zenster_bms\ui_view\ip_settings_dialog.dart",
    "lib\zenster_bms\ui_view\glass_view.dart",
    "lib\zenster_bms\ui_view\body_measurement.dart",
    "lib\zenster_bms\ui_view\area_list_view.dart",
    "lib\zenster_bms\my_diary\water_view.dart",
    "lib\zenster_bms\my_diary\meals_list_view.dart",
    "lib\zenster_bms\my_diary\app_usage_list_view.dart",
    "lib\zenster_bms\training\training_screen.dart",
    "lib\zenster_bms\bottom_navigation_view\bottom_bar_view.dart",
    "lib\zenster_bms\zenster_bms_home_screen.dart"
)

foreach ($file in $filesToUpdate) {
    if (Test-Path $file) {
        Write-Host "Updating $file"
        $content = Get-Content $file -Raw
        $content = $content -replace 'FitnessAppTheme', 'ZensterBMSTheme'
        $content = $content -replace "import '../zenster_bms_theme.dart';", "import '../zenster_bms_theme.dart';"
        Set-Content $file $content -NoNewline
    }
}

Write-Host "Completed updating files"
