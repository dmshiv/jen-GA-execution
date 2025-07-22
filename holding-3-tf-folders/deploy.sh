#!/bin/bash
set -euo pipefail

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Disable ALL Terraform locking
export TF_CLI_ARGS="-lock=false"
export TF_CLI_ARGS_init="-lock=false"
export TF_CLI_ARGS_plan="-lock=false"
export TF_CLI_ARGS_apply="-lock=false"
export TF_CLI_ARGS_destroy="-lock=false"

LAST_PATHS_FILE=".last_tf_paths"
projects=()
selected_projects=()

# 🔍 Better project detection that handles edge cases
function detect_tf_projects() {
  echo -e "\n${CYAN}📦 Scanning for Terraform projects...${NC}"
  projects=()

  # Find all valid Terraform directories (including root)
  while IFS= read -r -d '' dir; do
    # Verify it's actually a Terraform project (has .tf files)
    if ls "$dir"/*.tf &>/dev/null || [[ "$dir" == "." && $(ls *.tf 2>/dev/null | wc -l) -gt 0 ]]; then
      [[ "$dir" == "." ]] && projects+=(".") || projects+=("$dir")
    fi
  done < <(find . -mindepth 1 -maxdepth 3 -type f -name "*.tf" -exec dirname {} \; | sort -u | tr '\n' '\0')

  if [[ ${#projects[@]} -eq 0 ]]; then
    echo -e "${RED}❌ No valid Terraform projects found (checked current dir and 3 levels deep)${NC}"
    exit 1
  fi

  echo -e "\n${GREEN}📂 Detected Terraform projects:${NC}"
  for i in "${!projects[@]}"; do
    printf "${BLUE}%3d.${NC} %s\n" "$((i + 1))" "$([[ "${projects[$i]}" == "." ]] && echo "./" || echo "${projects[$i]}")"
  done
}

# 🚀 Robust execution engine with clean one-line output
function run_terraform() {
  local path="$1"
  local action="$2"
  local display_path="$([[ "$path" == "." ]] && echo "./" || echo "$path")"
  local output_line="${#selected_projects[@]}. $display_path"

  pushd "$path" >/dev/null || { echo -e "${RED}❌ Failed to enter directory${NC}"; return 1; }

  # 1. INIT
  echo -ne "${output_line} [init..."
  local start=$(date +%s)
  if terraform init -input=false -no-color &>/dev/null; then
    local duration=$(( $(date +%s) - start ))
    printf " ${GREEN}OK${NC} (%02dm%02ds)]" $((duration/60)) $((duration%60))
  else
    local duration=$(( $(date +%s) - start ))
    printf " ${RED}FAIL${NC} (%02dm%02ds)]" $((duration/60)) $((duration%60))
    popd >/dev/null
    return 1
  fi

  if [[ "$action" == "destroy" ]]; then
    # 2a. DESTROY FLOW
    echo -ne " [check..."
    start=$(date +%s)
    local resources=$(terraform state list 2>/dev/null | wc -l)
    duration=$(( $(date +%s) - start ))
    printf " ${YELLOW}%d resources${NC} (%02dm%02ds)]" "$resources" $((duration/60)) $((duration%60))

    if [[ $resources -eq 0 ]]; then
      printf " ${YELLOW}SKIPPED${NC}\n"
      popd >/dev/null
      return 0
    fi

    echo -ne " [destroy..."
    start=$(date +%s)
    if terraform destroy -auto-approve -input=false -no-color &>/dev/null; then
      duration=$(( $(date +%s) - start ))
      printf " ${GREEN}DONE${NC} (%02dm%02ds)]\n" $((duration/60)) $((duration%60))
    else
      duration=$(( $(date +%s) - start ))
      printf " ${RED}FAIL${NC} (%02dm%02ds)]" $((duration/60)) $((duration%60))

      # Recovery attempt
      echo -ne " [retry..."
      start=$(date +%s)
      terraform force-unlock -force $(terraform state list 2>/dev/null | head -1)
      if terraform destroy -auto-approve -input=false -no-color &>/dev/null; then
        duration=$(( $(date +%s) - start ))
        printf " ${GREEN}DONE${NC} (%02dm%02ds)]\n" $((duration/60)) $((duration%60))
      else
        duration=$(( $(date +%s) - start ))
        printf " ${RED}FAIL${NC} (%02dm%02ds)]\n" $((duration/60)) $((duration%60))
        popd >/dev/null
        return 1
      fi
    fi
  else
    # 2b. APPLY FLOW
    echo -ne " [plan..."
    start=$(date +%s)
    if terraform plan -input=false -no-color -out=tfplan &>/dev/null; then
      duration=$(( $(date +%s) - start ))
      printf " ${GREEN}OK${NC} (%02dm%02ds)]" $((duration/60)) $((duration%60))
    else
      duration=$(( $(date +%s) - start ))
      printf " ${RED}FAIL${NC} (%02dm%02ds)]" $((duration/60)) $((duration%60))
      popd >/dev/null
      return 1
    fi

    echo -ne " [apply..."
    start=$(date +%s)
    if terraform apply -input=false -no-color tfplan &>/dev/null; then
      duration=$(( $(date +%s) - start ))
      printf " ${GREEN}DONE${NC} (%02dm%02ds)]\n" $((duration/60)) $((duration%60))
    else
      duration=$(( $(date +%s) - start ))
      printf " ${RED}FAIL${NC} (%02dm%02ds)]\n" $((duration/60)) $((duration%60))
      popd >/dev/null
      return 1
    fi
  fi

  popd >/dev/null
  return 0
}

# 🌱 Main Execution
clear
echo -e "${GREEN}🌱 Terraform Automation Script${NC}"
echo -e "${BLUE}--------------------------------${NC}"
echo -e "1. ${CYAN}Apply${NC} (create/modify infrastructure)"
echo -e "2. ${RED}Destroy${NC} (tear down infrastructure)"
echo -ne "\n${YELLOW}➡️ Select operation (1-2): ${NC}"
read -r choice

case "$choice" in
  1|2)
    detect_tf_projects
    echo -e "\n${YELLOW}🧮 Enter project numbers (e.g., 1 3 5) or 'all': ${NC}"
    read -r order

    if [[ "$order" == "all" ]]; then
      selected_projects=("${projects[@]}")
    else
      for i in $order; do
        selected_projects+=("${projects[$((i-1))]}")
      done
    fi

    echo -e "\n${CYAN}➡️ Will execute:${NC}"
    for i in "${!selected_projects[@]}"; do
      printf "${YELLOW}%3d.${NC} %s\n" "$((i+1))" "$([[ "${selected_projects[$i]}" == "." ]] && echo "./" || echo "${selected_projects[$i]}")"
    done

    echo -ne "\n${GREEN}✅ Confirm? (y/n): ${NC}"
    read -r confirm
    [[ "$confirm" == "y" ]] || { echo -e "${RED}❌ Aborted.${NC}"; exit 1; }

    # Execute all projects
    for i in "${!selected_projects[@]}"; do
      path="${selected_projects[$i]}"
      if ! run_terraform "$path" "$([[ "$choice" == "1" ]] && echo "apply" || echo "destroy")"; then
        echo -e "\n${RED}⛔ Operation failed on $path${NC}"
        exit 1
      fi
    done

    [[ "$choice" == "1" ]] && printf "%s\n" "${selected_projects[@]}" > "$LAST_PATHS_FILE"
    ;;
  *)
    echo -e "${RED}❌ Invalid choice. Exiting.${NC}"
    exit 1
    ;;
esac
