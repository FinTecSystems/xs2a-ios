# XS2AiOSNetService

This is the networking service for the XS2A iOS SDK.

It used to be imported externally as a pre-built binary dependency. This turned out to be too much maintenance and came with too many issues, thus it is now directly
included with all source files - including it's own dependencies, some of which don't support i.e. CocoaPods.
