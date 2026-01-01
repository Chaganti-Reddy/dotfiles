#!/bin/bash

# --- CONFIGURATION ---
SEARCH_DIRS=(
    "$HOME/Downloads/"
    "$HOME/Desktop/"
    "$HOME/Documents/"
    "$HOME/dotfiles/"
    "$HOME/.config/"
)

RECENT_DB="$HOME/.vsc-recent.txt"
CACHE_FILE="/tmp/vsc_smart_cache_$USER"
CONFIG_HASH_FILE="/tmp/vsc_config_hash_$USER"

H_START="<span color='#ff9d00'><b>"
H_END="</b></span>|ns"
NESTED_HIDDEN_FILTER='/\.[^/]+.*/\.[^/]+'

mkdir -p "$(dirname "$RECENT_DB")"
touch "$RECENT_DB"

# --- NOTIFICATION HELPER ---
NOTIFY_ID_FILE="/tmp/vsc_notify_id_$USER"
msg() {
    local message="$1"
    local icon="${2:-info}"
    local expire="${3:-2000}"
    local last_id=$(cat "$NOTIFY_ID_FILE" 2>/dev/null || echo 0)
    notify-send -p -r "$last_id" -i "$icon" -t "$expire" "VSC Project Manager" "$message" >"$NOTIFY_ID_FILE"
}

# --- HELPER: PATH NORMALIZATION ---
norm_path() {
    echo "$1" | sed 's|/*$||' | xargs realpath -m 2>/dev/null
}

# --- CACHING ENGINE ---
refresh_cache() {
    msg "Scanning disk for projects..." "view-refresh-symbolic" 5000
    (
        # Find Git repos first and tag with |1
        fd -H -t d '^.git$' "${SEARCH_DIRS[@]}" --max-depth 4 -x echo '{//}|1'
        # Find General folders and tag with |0
        fd -H -t d --max-depth 2 . "${SEARCH_DIRS[@]}" | grep -vE "$NESTED_HIDDEN_FILTER" | sed 's/$/|0/'
    ) | while read -r line; do
        p_raw="${line%|*}"
        flag="${line#*|}"
        echo "$(norm_path "$p_raw")|$flag"
    done | awk -F'|' '!seen[$1]++' >"$CACHE_FILE"

    echo "${SEARCH_DIRS[@]}" | md5sum >"$CONFIG_HASH_FILE"
    msg "Cache updated!" "emblem-ok-symbolic" 1500
}

# --- DYNAMIC RANKER ---
get_ranked_projects() {
    local counts_logic=""
    # We pass the index (i) of the array to AWK to use as a tie-breaker
    for i in "${!SEARCH_DIRS[@]}"; do
        dir="${SEARCH_DIRS[$i]}"
        count=$(grep -c "^$dir" "$RECENT_DB")
        counts_logic+="${dir},${count},${i} "
    done

    # Output priority:
    # 1. Usage Score (Higher better)
    # 2. Array Position (Lower index better)
    # 3. Is Git (1 better than 0)
    # 4. Path (Alphabetical)
    awk -v counts="$counts_logic" -F'|' '
    BEGIN {
        split(counts, arr, " ")
        for (i in arr) {
            split(arr[i], pair, ",")
            scores[pair[1]] = pair[2]   # Count
            pos[pair[1]] = pair[3]     # Array Index
        }
    }
    {
        path = $1; is_git = $2; 
        score = 0; rank = 999;
        for (s in scores) {
            if (index(path, s) == 1) {
                # We want the highest score and lowest rank (position)
                if (scores[s] >= score) {
                    score = scores[s]
                    if (pos[s] < rank) rank = pos[s]
                }
            }
        }
        print score "|" rank "|" is_git "|" path
    }' "$CACHE_FILE" | sort -t'|' -k1,1rn -k2,2n -k3,3rn -k4,4 | cut -d'|' -f3-
}

# --- VALIDATION LOGIC ---
validate_data() {
    if [ -f "$RECENT_DB" ]; then
        tmp_recent=$(mktemp)
        while read -r line; do [ -d "$line" ] && echo "$line"; done < <(tac "$RECENT_DB") | awk '!seen[$0]++' | tac >"$tmp_recent"
        mv "$tmp_recent" "$RECENT_DB"
    fi

    current_hash=$(echo "${SEARCH_DIRS[@]}" | md5sum)
    old_hash=$(cat "$CONFIG_HASH_FILE" 2>/dev/null)

    if [ "$current_hash" != "$old_hash" ] || [ ! -f "$CACHE_FILE" ] || ! grep -q "|" "$CACHE_FILE"; then
        refresh_cache
    fi
}

validate_data
SCOPE_DIR=""

while true; do
    mapfile -t RECENT_ARRAY < <(tac "$RECENT_DB" | head -n 10)
    MENU_ITEMS=()

    if [ -z "$SCOPE_DIR" ]; then
        PROMPT="[Global] Projects (CTRL-O to directly open)"
        MENU_ITEMS+=("${H_START}─── RECENT PROJECTS ───${H_END}")
        for r in "${RECENT_ARRAY[@]}"; do
            [ -n "$r" ] && MENU_ITEMS+=("⌚ $r/")
        done

        MENU_ITEMS+=("${H_START}─── DISCOVERED PROJECTS ───${H_END}")

        while read -r line; do
            is_git="${line%%|*}"
            p_norm="${line#*|}"
            [[ -z "$p_norm" ]] && continue

            is_recent=false
            for r_norm in "${RECENT_ARRAY[@]}"; do
                [[ "$p_norm" == "$r_norm" ]] && is_recent=true && break
            done

            if [ "$is_recent" = false ]; then
                if [[ "$is_git" == "1" ]]; then icon="󰊢"; else icon="󰉋"; fi
                MENU_ITEMS+=("$icon $p_norm/")
            fi
        done < <(get_ranked_projects)

        MENU_ITEMS+=("${H_START}─── OPTIONS ───${H_END}" "󰑐 Force Refresh Cache")
    else
        PROMPT="[Exploring $(basename "$SCOPE_DIR")]"
        MENU_ITEMS+=("󰌍 .. [Go Back]" "󰩉 .. [Main Menu]")
        while read -r p; do
            pn=$(norm_path "$p")
            icon=$([ -d "$pn/.git" ] && echo "󰊢" || echo "󰉋")
            MENU_ITEMS+=("$icon $pn/")
        done < <(fd -H -t d --max-depth 1 . "$SCOPE_DIR" | grep -vE "$NESTED_HIDDEN_FILTER" | sort -V)
    fi

    SELECTED=$(printf "%s\n" "${MENU_ITEMS[@]}" |
        sed 's/|ns/\x00nonselectable\x1ftrue/' |
        rofi -dmenu -i -p "$PROMPT" -markup-rows -width 1200)

    EXIT_CODE=$?
    [[ -z "$SELECTED" || "$EXIT_CODE" -eq 1 ]] && exit 0

    if [[ "$SELECTED" == *"Force Refresh Cache"* ]]; then
        refresh_cache
        continue
    fi

    if [[ "$SELECTED" == *"Go Back"* ]]; then
        SCOPE_DIR=$(dirname "$SCOPE_DIR")
        continue
    elif [[ "$SELECTED" == *"Main Menu"* ]]; then
        SCOPE_DIR=""
        continue
    fi

    CLEAN_PATH=$(echo "$SELECTED" | sed 's/^[⌚󰊢󰉋󰌍󰩉] //' | sed 's|/$||')
    CLEAN_PATH=$(norm_path "$CLEAN_PATH")

    ACT_PROMPT="Action: $(basename "$CLEAN_PATH")"
    CONFIRM=$(printf "1. Open in Code\n2. Explore Sub-folders\n3. Cancel" | rofi -dmenu -i -p "$ACT_PROMPT" -width 400)

    case "$CONFIRM" in
    "1."*)
        sed -i "\|^$CLEAN_PATH$|d" "$RECENT_DB"
        echo "$CLEAN_PATH" >>"$RECENT_DB"
        code "$CLEAN_PATH"
        exit 0
        ;;
    "2."*)
        SCOPE_DIR="$CLEAN_PATH"
        continue
        ;;
    *) continue ;;
    esac
done
