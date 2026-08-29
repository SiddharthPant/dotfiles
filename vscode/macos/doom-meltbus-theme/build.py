#!/usr/bin/env python3
"""Regenerate the Meltbus theme files.

Merges VS Code's stock 2026 Dark/Light include chains into flat `colors`
snapshots, then layers the Meltbus monochrome token palette on top. Rerun
after a VS Code update if the stock themes drift, then bump the version in
package.json and repackage.
"""
import json
import re
from pathlib import Path

STOCK = Path(
    "/Applications/Visual Studio Code.app/Contents/Resources/app/extensions/theme-defaults/themes"
)
OUT = Path(__file__).parent / "themes"

# Dark ramp (from Emacs doom-meltbus) and its light-mode mirror.
# Grays are channel-inverted; accent hues are hand-darkened for white bg.
DARK_TO_LIGHT = {
    "#dddddd": "#222222",  # default / prominent
    "#acacac": "#535353",  # strings, types, punctuation
    "#8a8a8a": "#757575",  # built-ins, operators, docs
    "#686868": "#979797",  # comments
    "#87afff": "#2f6fba",  # links
    "#f88080": "#c03030",  # invalid
    "#7cab7c": "#3f7a3f",  # diff inserted
    "#fac7c7": "#b05050",  # diff deleted
    "#da8548": "#b05f2b",  # diff changed
}

BRACKETS_DARK = ["#dddddd", "#a9a1e1", "#7cab7c", "#cdad00", "#db7093", "#87afff"]
BRACKETS_LIGHT = ["#222222", "#7c3aed", "#16a34a", "#ca8a04", "#db2777", "#2563eb"]


def load_jsonc(path):
    s = path.read_text(encoding="utf-8")
    s = re.sub(r"^\s*//.*$", "", s, flags=re.M)
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)


def merge_chain(entry):
    """Resolve a stock theme's include chain into flat colors + tokenColors.

    Colors: shallower files win. Token rules: included files' rules come
    first, the includer's are appended after — matching VS Code's own
    include resolution, so later (shallower) rules win specificity ties.
    """
    files, name = [], entry
    while name:
        data = load_jsonc(STOCK / name)
        files.append(data)
        name = data.get("include")
        name = name.lstrip("./") if name else None
    colors, tokens = {}, []
    for data in reversed(files):
        colors.update(data.get("colors", {}))
        tokens.extend(data.get("tokenColors", []))
    return colors, tokens


def dark_tokens():
    return json.loads((Path(__file__).parent / "tokens-dark.json").read_text())


def to_light(tokens):
    light = json.loads(json.dumps(tokens))
    for rule in light:
        fg = rule["settings"].get("foreground")
        if fg:
            rule["settings"]["foreground"] = DARK_TO_LIGHT[fg]
    return light


def build(name, theme_type, stock_entry, brackets, tokens, out_name):
    colors, stock_tokens = merge_chain(stock_entry)
    for i, color in enumerate(brackets, 1):
        colors[f"editorBracketHighlight.foreground{i}"] = color
    theme = {
        "name": name,
        "type": theme_type,
        "semanticHighlighting": False,
        "colors": colors,
        # Stock rules first, Meltbus appended after so scopes Meltbus covers
        # go monochrome while everything else keeps its stock 2026 color —
        # same layering the settings-based customizations had.
        "tokenColors": stock_tokens + tokens,
    }
    (OUT / out_name).write_text(json.dumps(theme, indent=2) + "\n")
    print(f"{out_name}: {len(colors)} colors, {len(tokens)} token rules")


if __name__ == "__main__":
    tokens = dark_tokens()
    build("Meltbus Dark", "dark", "2026-dark.json", BRACKETS_DARK, tokens,
          "meltbus-dark-color-theme.json")
    build("Meltbus Light", "light", "2026-light.json", BRACKETS_LIGHT, to_light(tokens),
          "meltbus-light-color-theme.json")
