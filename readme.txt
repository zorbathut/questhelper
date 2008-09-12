If you're reading this, you're probably interested in doing development on this codebase.

Ha ha, you poor, poor fool.

The codebase is, shall we say, interesting. There is much duplicated code and few comments. There are many tables without text labels, just indexes (I'm going to assume this is for efficiency reasons - QuestHelper uses a good swath of RAM anyway.) Deciphering it all is taking *quite* a long time, and so I'm going to write notes here about what I'm discovering. Hopefully this will assist if anyone else decides to do the same thing.

First off, QuestHelper uses a separate coroutine for routing, which yields occasionally. Originally there was some nasty heuristic for CPU usage, which is now gone entirely, so all those yieldIfNeeded calls have a parameter which is utterly ignored. (I may have gotten rid of them by the time you read this.) Obviously, if it's getting slow and spiky, it needs more of those calls.

There appears to be no way to get a stack dump from the routing thread unless you use the QuestHelper:Assert function. I actually added that function myself, so most places don't use it yet. Addendum: Yeah it's impossible. I hate Lua.

The position tables all have the same format: { ZoneID, X, Y, Weight }. The ZoneID lookup table can be found in upgrade.lua - I'm not sure if that file is called when doing general lookups, or what. Weight is used when combining multiple positions together. I may have to modify this *heavily* to gather more useful information, since this means a substantial amount of data has been lost (note: argh)



Zone data: { [ Table of zone links ], i=zone index, c=continent, z=zone }

There seems to be another type of position that's used in some places, with the format { Zone_data, Distances_to_zone_links_in_Zone_data, X, Y, (weight1), Text, (weight2) }. I'm not entirely sure what the difference between the two Weight's is - the second seems to be the weight of the text, the first is just the weight of the node in general. This appears to be the "more common" position. I'm pretty sure X and Y are in global units.



AddLoc in objective.lua is important. It's combining chunks of points in some manner. It combines things that are "close" by accumulating them into a single item in a large array of points - self.p[list][whatever]. What I haven't figured out is what "list" is - self.qh.zone_nodes[index], but what's index?

what's the difference between .o. and .fb.?


