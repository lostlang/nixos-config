{
  colorScheme,
  user,
  ...
}:
let
  themeName = colorScheme.default.name;
  palette = colorScheme.default.palette;
in
''
  #Bashtop "${themeName}" theme
  #by ${user}

  # Colors should be in 6 or 2 character hexadecimal or single spaced rgb decimal: "#RRGGBB", "#BW" or "0-255 0-255 0-255"
  # example for white: "#FFFFFF", "#ff" or "255 255 255".

  # All graphs and meters can be gradients
  # For single color graphs leave "mid" and "end" variable empty.
  # Use "start" and "end" variables for two color gradient
  # Use "start", "mid" and "end" for three color gradient

  # Main background, empty for terminal default, need to be empty if you want transparent background
  theme[main_bg]="${palette.light_white}"

  # Main text color
  theme[main_fg]="${palette.black}"

  # Title color for boxes
  theme[title]="${palette.green}"

  # Highlight color for keyboard shortcuts
  theme[hi_fg]="${palette.orange}"

  # Background color of selected item in processes box
  theme[selected_bg]="${palette.light_black}"

  # Foreground color of selected item in processes box
  theme[selected_fg]="${palette.white}"

  # Color of inactive/disabled text
  theme[inactive_fg]="${palette.white}"

  # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
  theme[proc_misc]="${palette.purple}"

  # Cpu box outline color
  theme[cpu_box]="${palette.green}"

  # Memory/disks box outline color
  theme[mem_box]="${palette.green}"

  # Net up/down box outline color
  theme[net_box]="${palette.green}"

  # Processes box outline color
  theme[proc_box]="${palette.green}"

  # Box divider line and small boxes line color
  theme[div_line]="${palette.green}"

  # Temperature graph colors
  theme[temp_start]="${palette.light_green}"
  theme[temp_mid]="${palette.light_red}"
  theme[temp_end]="${palette.red}"

  # CPU graph colors
  theme[cpu_start]="${palette.aqua}"
  theme[cpu_mid]="${palette.orange}"
  theme[cpu_end]="${palette.red}"

  # Mem/Disk free meter
  theme[free_start]="${palette.light_aqua}"
  theme[free_mid]=""
  theme[free_end]="${palette.aqua}"

  # Mem/Disk cached meter
  theme[cached_start]="${palette.light_purple}"
  theme[cached_mid]=""
  theme[cached_end]="${palette.purple}"

  # Mem/Disk available meter
  theme[available_start]="${palette.light_green}"
  theme[available_mid]=""
  theme[available_end]="${palette.green}"

  # Mem/Disk used meter
  theme[used_start]="${palette.light_red}"
  theme[used_mid]=""
  theme[used_end]="${palette.red}"

  # Download graph colors
  theme[download_start]="${palette.light_blue}"
  theme[download_mid]="${palette.blue}"
  theme[download_end]="${palette.light_black}"

  # Upload graph colors
  theme[upload_start]="${palette.white}"
  theme[upload_mid]="${palette.light_orange}"
  theme[upload_end]="${palette.orange}"
''
