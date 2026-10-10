# CMPlayer.Linux
License: **GPL-3.0-or-later**  
This is a console music player for macOS.  

## Application
The applications name is **cmplayer** and the following arguments are supported:  
 - --help                    = shows this help screen  
 - --version                 = show version number  
 - --integrity-check         = does a quick integrity check of cmplayer  
 - --purge                   = remove all stored data  
 - --set-output-api-ao       = sets audio output api to libao (ao)  
 - --set-output-api-alsa     = sets audio output api to libasound (alsa)  
 - --get-output-api          = gets audio output api  
 - --set-max-log-n max       = sets max log entries [25,1000]  
 - --get-max-log-n           = gets max log entries
 - --set-max-history-n max   = sets max history entries [25,1000]
 - --get-max-history-n       = gets max history entries
 - --get-format              = gets music formats to try and play
 - --add-format <.ext>       = adds a format to music formats to play
 - --remove-format <.ext>    = removes a format from music formats
 - --log-information-on      = turn on information logging
 - --log-information-off     = turn off information logging
 - --log-warning-on          = turn on warning logging
 - --log-warning-off         = turn off warning logging
 - --log-error-on            = turn on error logging
 - --log-error-off           = turn off error logging
 - --log-debug-on            = turn on debug logging
 - --log-debug-off           = turn off debug logging
 - --log-other-on            = turn on other logging
 - --log-other-off           = turn off other logging
 - --get-log-status          = gets log status  
  
## Supported File Formats
The following file formats are default supported:
 - .mp3  
 - .m4a  
  
You can add more file types by using the --add-format/--remove-format  
and --get-format command line arguments.  
  
## Libraries
The player uses the following tools and libraries:  
 - Swift (version 5.10.1+)
 - libmpg123 (libmpg123.so)
 - ffmpeg
 - libavcodec (libavcodec.so)
 - libavformat (libavformat.so)
 - libavutil (libavutil.so)
  
## macOS
In order to get these libraries onto your Ubuntu distro, you can execute the following commands:  
 - sudo apt install ffmpeg
 - sudo apt install libavcodec-dev
 - sudo apt install libavformat-dev
 - sudo apt install libmpg123-dev
   
## Preprocessor Flags
There are the following preprocessor flags defined in Package.swift:
### cSettings and swiftSettings
 - CMP_FFMPEG_V7            (ffmpeg v7)
 - CMP_FFMPEG_V6            (ffmpeg v6)
 - CMP_FFMPEG_V5            (ffmpeg v5)
 - CMP_FFMPEG_V4            (ffmpeg v4)
 - CMP_PLATFORM_ARM64       (ARM64 distro)
  
Uncomment any flag that is not appropriate.  
  
## Header Files
The following are the location of include header files to the  
Swift C wrapper libraries used by CMPlayer.Linux.    
### Cffmpeg (swift C wrapper library for ffmpeg)
Are located at:
 - /usr/include/x86_64-linux-gnu/*library* (Ubuntu 22.04, 24.04)
 - /usr/include/ffmpeg/*library* (Fedora 40)
 - /usr/include/*library* (Manjaro 24)
  
### Cmpg123 (swift C wrapper library for libmpg123)
Are located at:
 - /usr/include/ (Ubuntu 22.04)
 - /usr/include/x86_64-linux-gnu/ (Ubuntu 24.04)
 - /usr/include/ (Fedora 40)
 - /usr/include/ (Manjaro 24)
  
## How to build CMPlayer.macOS
CMPlayer.macOS is written in Swift.

Building **cmplayer** is relativly easy. After you clone the  
project using the following:  
```bash
git clone https://github.com/sith-ikjetil/CMPlayer.macOS.git
```
You first must edit Package.swift in the CMPlayer.Linux directory.  
You must uncomment the .define statements that apply, and comment out  
those that do not apply. Like this:  
```swift
cSettings: [
    .define("CMP_PLATFORM_AMD64"),
    //.define("CMP_PLATFORM_ARM64"),
    .define("CMP_TARGET_UBUNTU_V22_04"),
    //.define("CMP_TARGET_UBUNTU_V24_04"),
    //.define("CMP_TARGET_FEDORA_V40"),
    //.define("CMP_TARGET_MANJARO_V24"),
    .define("CMP_FFMPEG_V4"),
    //.define("CMP_FFMPEG_V5"),
    //.define("CMP_FFMPEG_V6"),
    //.define("CMP_FFMPEG_V7"),
],
swiftSettings: [
    .define("CMP_PLATFORM_ARM64"),
    .define("CMP_FFMPEG_V4"),
    //.define("CMP_FFMPEG_V5"),
    //.define("CMP_FFMPEG_V6"),
    //.define("CMP_FFMPEG_V7"),
]
```
You then need to stay in the CMPlayer.macOS directory and  execute the  
following commands:  
```bash
swift build
```
If you get compiler errors, you might need the **C_INCLUDE_PATH** set in  
your .bashrc and .bash_profile. If it builds without errors, you can then  
build for release using the command:  
```bash
swift build -c release
```
If it once again builds without errors, you can find the binary in  
the CMPlayer.macOS/.build/release directory. Then it is simply a job  
to copy **cmplayer** to /usr/bin and execute the application.  
  
You might get runtime errors for libraries that **cmplayer** depends on  
but are not installed. It is written about further up in this README.md  
file. You might also need to have gcc and g++ installed. See also  
**LD_LIBRARY_PATH** further up. 
