#!/bin/bash
set -euo pipefail

BASE_DIR="$HOME/.local/share/powershell/Modules"
mkdir -p "$BASE_DIR"

declare -A MODULES=(
  ["PackageManagement"]="1.4.8.1"
  ["PowerShellGet"]="2.2.5"
  ["NuGet"]="2.8.5.208"
)

for module in "${!MODULES[@]}"; do
  version="${MODULES[$module]}"
  target_dir="$BASE_DIR/$module/$version"
  nupkg_file="/tmp/${module}.${version}.nupkg"

  if [[ -f "$target_dir/${module}.psd1" ]]; then
    echo "✅ $module $version already exists at $target_dir"
    continue
  fi

  echo "⬇️  Downloading $module $version..."
  curl -sSL -o "$nupkg_file" "https://www.powershellgallery.com/api/v2/package/$module/$version"

  echo "📦 Unpacking $module to $target_dir..."
  mkdir -p "$target_dir"
  unzip -q "$nupkg_file" -d "$target_dir"
  rm -f "$nupkg_file"

  echo "✅ $module $version installed at $target_dir"
done
