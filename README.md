# Audio Duration Script

This script calculates the total duration of audio files in a directory and lists the durations of individual tracks. It works with a variety of audio formats such as MP3, FLAC, WAV, AAC, ALAC, M4A, AIFF, and Ogg Vorbis. The script extracts metadata from the files to display the track names, and it offers the option to output the results to a text file.

## Features

- Calculates the total duration of all audio files in a directory.
- Lists each track's name and its duration.
- Outputs in a neatly formatted table.
- Allows for output to be saved to a file.
- Removes album names from track titles using metadata.

## Requirements

- `ffprobe` (part of FFmpeg) must be installed.
  - On Linux, you can install it using your package manager (e.g., `sudo apt install ffmpeg` on Ubuntu or `sudo pacman -S ffmpeg` on Arch Linux).
- Bash shell (Linux/Mac/WSL).

## Usage

### Basic Usage:
```bash
./audio_duration.sh
```
## Example Output
````
Total Duration: 00:37:03
Track List:
--------------------------------------------------------------------------------
No.  Track Name                                    Duration
--------------------------------------------------------------------------------
01   Track 1                                       00:05:18
02   Track 2                                       00:03:16
03   Track 3                                       00:05:40
04   Track 4                                       00:04:26
05   Track 5                                       00:04:51
06   Track 6                                       00:05:59
07   Track 7                                       00:07:31
--------------------------------------------------------------------------------
````

## Supported Formats

- MP3
- FLAC
- WAV
- AAC
- ALAC
- M4A
- AIFF
- Ogg Vorbis

## Notes

- The script strips album names and extra numbering to show only the track name for each song.
- The total duration and track durations are displayed in the HH:MM:SS format.
