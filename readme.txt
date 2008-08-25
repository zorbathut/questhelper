If you're reading this, you're probably interested in doing development on this codebase.

Ha ha, you poor, poor fool.

The codebase is, shall we say, interesting. There is much duplicated code and few comments. There are many tables without text labels, just indexes (I'm going to assume this is for efficiency reasons - QuestHelper uses a good swath of RAM anyway.) Deciphering it all is taking *quite* a long time, and so I'm going to write notes here about what I'm discovering. Hopefully this will assist if anyone else decides to do the same thing.

First off, QuestHelper uses a separate coroutine for routing, which yields occasionally. Originally there was some nasty heuristic for CPU usage, which is now gone entirely, so all those yieldIfNeeded calls have a parameter which is utterly ignored. (I may have gotten rid of them by the time you read this.) Obviously, if it's getting slow, it needs more of those calls.

There appears to be no way to get a stack dump from the routing thread unless you use the QuestHelper:Assert function. I actually added that function myself, so most places don't use it yet.

The position tables all have the same format: { ZoneID, X, Y, Unknown }. The ZoneID lookup table can be found in upgrade.lua - I'm not sure if that file is called when doing general lookups, or what. I obviously haven't figured out what Unknown is yet.