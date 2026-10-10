# CMPlayer.Linux
License: **GPL-3.0-or-later**  
This is a console music player for macOS.  

## Application
The applications name is **cmplayer** and the following arguments are supported:  
 - --help                    = shows this help screen  
 - --version                 = show version number  
 - --integrity-check         = does a quick integrity check of cmplayer  
 - --purge                   = remove all stored data  
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
and --get-format command line arguments. Must be supported by AVFoundation.  
     
## Preprocessor Flags
There are the following preprocessor flags defined in Package.swift:
### cSettings and swiftSettings
 - CMP_PLATFORM_ARM64       (ARM64 distro)
 - CMP_TARGET_MACOS_V27.    (macOS 27) 
Uncomment any flag that is not appropriate.  
    
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
    .define("CMP_PLATFORM_ARM64"),
    .define("CMP_TARGET_MACOS_V27"),
],
swiftSettings: [
    .define("CMP_PLATFORM_ARM64"),
    .define("CMP_TARGET_MACOS_V27"),
]
```
You then need to stay in the CMPlayer.macOS directory and execute the  
following debug build command:  
```bash
swift build
```
or the following release build command:  
```bash
swift build -c release
```
If it builds without errors, you can find the binary in  
the CMPlayer.macOS/.build/(debug or release) directory. Then it is simply a job  
to copy **cmplayer** to /usr/bin and execute the application.  
