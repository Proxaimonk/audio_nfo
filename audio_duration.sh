#!/bin/bash

# Default values
DIR="."
OUTPUT_FILE=""
EXTENSIONS=("mp3" "flac" "aac" "wav" "m4a" "alac" "aiff" "ogg")

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--directory)
            DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Build find conditions
find_conditions=()
for ext in "${EXTENSIONS[@]}"; do
    find_conditions+=( -iname "*.${ext}" -o )
done
unset 'find_conditions[${#find_conditions[@]}-1]'  # Remove trailing -o

# Find audio files
mapfile -t audio_files < <(find "$DIR" -type f \( "${find_conditions[@]}" \) | sort)

if [[ ${#audio_files[@]} -eq 0 ]]; then
    echo "No supported audio files found."
    exit 1
fi

# Initialize
total_seconds=0
track_list=()
max_name_length=0

# Function to get track name from metadata (fallback to filename if missing)
get_track_name() {
    local file="$1"
    # Get track title from metadata
    track_name=$(ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$file")

    # If no title is found, fallback to filename (excluding extension)
    if [[ -z "$track_name" ]]; then
        filename=$(basename "$file")
        track_name="${filename%.*}"  # Remove file extension
    fi

    echo "$track_name"
}

# Extract durations and metadata
for i in "${!audio_files[@]}"; do
    file="${audio_files[$i]}"
    filename=$(basename "$file")

    # Get track name from metadata (or fallback to filename)
    track_name=$(get_track_name "$file")

    # Get raw duration in seconds
    duration_sec=$(ffprobe -v error -select_streams a:0 \
        -show_entries stream=duration \
        -of default=noprint_wrappers=1:nokey=1 "$file")

    # Skip invalid durations
    if ! [[ $duration_sec =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        continue
    fi

    # Sum duration
    total_seconds=$(echo "$total_seconds + $duration_sec" | bc)

    # Convert duration to integers for formatting (round down to seconds)
    duration_sec_int=$(echo "$duration_sec / 1" | bc)

    # Format duration to HH:MM:SS (using integer math)
    h=$(echo "$duration_sec_int / 3600" | bc)
    m=$(echo "($duration_sec_int % 3600) / 60" | bc)
    s=$(echo "$duration_sec_int % 60" | bc)

    duration_formatted=$(printf "%02d:%02d:%02d" "$h" "$m" "$s")

    # Format track number
    track_num=$(printf "%02d" $((i + 1)))

    # Track longest filename for padding
    name_length=${#track_name}
    (( name_length > max_name_length )) && max_name_length=$name_length

    # Save data
    track_list+=("$track_num|$track_name|$duration_formatted")
done

# Format total duration
total_seconds_int=$(echo "$total_seconds / 1" | bc)  # Convert to integer
h=$(echo "$total_seconds_int / 3600" | bc)
m=$(echo "($total_seconds_int % 3600) / 60" | bc)
s=$(echo "$total_seconds_int % 60" | bc)
total_formatted=$(printf "%02d:%02d:%02d" "$h" "$m" "$s")

# Output header
name_column_width=$((max_name_length + 2))
duration_column_width=8

output=""
printf "Total Duration: %s\n" "$total_formatted"
printf "Track List:\n"
printf "%s\n" "$(printf '%0.s-' {1..80})"
printf "%-4s %-$(($name_column_width))s %-${duration_column_width}s\n" "No." "Track Name" "Duration"
printf "%s\n" "$(printf '%0.s-' {1..80})"

# Output track list
for entry in "${track_list[@]}"; do
    IFS="|" read -r num name dur <<< "$entry"
    printf "%-4s %-$(($name_column_width))s %-${duration_column_width}s\n" "$num" "$name" "$dur"
done

printf "%s\n" "$(printf '%0.s-' {1..80})"

# Optional output file
if [[ -n $OUTPUT_FILE ]]; then
    {
        printf "Total Duration: %s\n" "$total_formatted"
        printf "Track List:\n"
        printf "%s\n" "$(printf '%0.s-' {1..80})"
        printf "%-4s %-$(($name_column_width))s %-${duration_column_width}s\n" "No." "Track Name" "Duration"
        printf "%s\n" "$(printf '%0.s-' {1..80})"
        for entry in "${track_list[@]}"; do
            IFS="|" read -r num name dur <<< "$entry"
            printf "%-4s %-$(($name_column_width))s %-${duration_column_width}s\n" "$num" "$name" "$dur"
        done
        printf "%s\n" "$(printf '%0.s-' {1..80})"
    } > "$OUTPUT_FILE"
    echo "Result saved to $OUTPUT_FILE"
fi
