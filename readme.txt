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




Graph nodes contain a few temporary values that seem to be essentially globals
.e: distance to zone boundary, I think? Maybe "closest distance we've found"?
.w: always 1?
.s: "state", uncertain meaning. 3 and 4 seem to mean visited, 0 and 1 mean something else.
.g: cost made by the graph



The standard shortest-path functions all work pretty much the same way and have a ton of duplicated code (todo: unduplicate code)

The most basic one is ComputeTravelTime. It takes two points and finds the shortest path between them (actually, it's buggy, it finds the shortest path to get from A to the zone B is in, then goes to B from there. We'll ignore this.)

Next is ComputeRoute. I think this does the same thing, only it also returns the last travel point the route goes through. It is buggy in the same way.

After that there's ObjectiveTravelTime. It does almost exactly the same thing, only it goes from a point to a *set* of points. Naturally, the arguments are in reverse order, because the codebase is retarded. It also does something with weighting that I don't yet understand. It is likewise buggy.

Finally, there's ObjectiveTravelTime2. That function name? That's the mark of *quality*. It goes from a point, to a set of points, to a point. Actually it goes point->set and point->set simultaneously. This is important because, due to the bugs, its paths are not symmetrical. It also fucks with weighting. Right now? It doesn't do any of that. It's implemented as a call to ObjectiveTravelTime and a call to ComputeRoute, meaning it's somewhat less efficient and makes me far, far happier.



Here now I'm working on it for real, have some dev notes:



0.51: Got Wrath support in. This was nasty, largely due to the change in Stormwind City and Eastern Plaguelands' coordinates. At the moment, there's basically three coordinate systems used: "BC", "Wrath", and "Native". static.lua is stored in Wrath format - if you're playing on a BC client, it does a pass over the entire static.lua and changes it when you start up (it can't write, obviously, so it just replaces everything necessary each time you start.)

The output file has been split into versions, both by QH version and WoW version. Most versions are now "unknown on unknown", since they predate the new versioning system.

"* on 2.*" uses BC coordinates. "* on 3.*" uses Wrath coordinates. Since it only loads the type that matches the current version, this means it's always in Native mode.

Downside: if you gather information, then upgrade QH or the WoW client, your QH installation will no longer know about any info you've gathered. /qh nag is smart enough to notice it, but it won't be used for quest suggestions. I'm not considering this a huge problem since people should be uploading files anyway and I have limited sympathy if they're not.

Astrolabe needed some modifications - they hadn't added Eastern Plaguelands. This is now done, we're using a forked Astrolabe.

I found a bug involving flight path timing for paths that zoned - most notably, Stormwind->Quel'Danas and Quel'Danas->Menethil were so ridiculously low that the program actually thought that was a faster way than going through Stormwind. I fixed the timing bug by changing how it determines when a flight path is done, and manually eradicated the information. Once a few more 0.51 files come in, I'll rig it to ignore pre-0.51 flight path data if 0.51 flight path data exists. Stupid corrupted data.

I think there might have been another tweak or two but I'm going to bed and I've forgotten what they were.

0.52: Realized I'd forgotten Dalaran portals, added Dalaran portals. Grabbed a chunk of code to compress lua files and applied it to static.lua, which is now about 25% smaller bytewise (but probably takes up the same amount of RAM.)

