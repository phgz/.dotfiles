from glob import glob
from pathlib import Path
import re

registered_themes = (Path.home() / ".dotfiles/fish/functions/_random_helix_theme.fish").read_text()
day_themes = re.search(r"set -f day(.*)\n", registered_themes)[1].split()
evening_themes = re.search(r"set -f evening(.*)\n", registered_themes)[1].split()

default_themes_dir = Path(glob("/opt/homebrew/Cellar/helix/HEAD-*/libexec/runtime/themes/")[0])
 
for file in default_themes_dir.iterdir():
    if file.suffix == ".toml" and not (file.stem in day_themes or file.stem in evening_themes):
        print(file)

print("-" * 80)

file_themes = [file.stem for file in default_themes_dir.iterdir() if file.suffix == ".toml"]
for theme in day_themes + evening_themes:
    if not theme in file_themes:
        print(theme)
