#!/bin/bash
echo "🚀 Generating MVVM folder structure..."
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
BASE="lib"
FOLDERS=(
  "$BASE/core/constants" "$BASE/core/theme" "$BASE/core/utils"
  "$BASE/data/models" "$BASE/data/repositories" "$BASE/data/services"
  "$BASE/features/auth/view" "$BASE/features/auth/viewmodel" "$BASE/features/auth/widgets"
  "$BASE/features/home/view" "$BASE/features/home/viewmodel" "$BASE/features/home/widgets"
  "$BASE/features/library/view" "$BASE/features/library/viewmodel" "$BASE/features/library/widgets"
  "$BASE/features/player/view" "$BASE/features/player/viewmodel" "$BASE/features/player/widgets"
  "$BASE/features/now_playing/view" "$BASE/features/now_playing/viewmodel" "$BASE/features/now_playing/widgets"
  "$BASE/features/search/view" "$BASE/features/search/viewmodel" "$BASE/features/search/widgets"
  "$BASE/features/profile/view" "$BASE/features/profile/viewmodel" "$BASE/features/profile/widgets"
  "$BASE/features/premium/view" "$BASE/features/premium/viewmodel"
  "$BASE/shared/widgets" "$BASE/shared/providers"
)
for FOLDER in "${FOLDERS[@]}"; do
  mkdir -p "$FOLDER"
  touch "$FOLDER/.gitkeep"
  echo -e "  ${GREEN}✓${NC} $FOLDER"
done
echo -e "\n${YELLOW}📁 Struktur MVVM berhasil dibuat!${NC}\n"
echo -e "${GREEN}✅ Done! Happy refactoring 🎯${NC}"
