---
name: trip-collections
description: Organize saved Trip places into collections, read or rename a shortlist, or schedule a saved collection place onto a trip day. Use for saving an itinerary place to a shortlist or adding an unscheduled shortlist place to an existing day. Not for booking travel, inventing places, or moving an existing itinerary visit.
---

# Organize a saved-place shortlist

Resolve the saved trip and collection first. Matching collection names can belong
to different trips; ask when the target is ambiguous. Collection entities include
their trip, current place count, and saved names, including unscheduled places.

Use Read Trip Collection to read the current shortlist. Its spoken summary may
include only the first three places; the returned list contains all saved names.
Do not interpret a collection place as scheduled, booked, or already visited.
Private notes are not available through this action.

For an explicitly requested new shortlist, use Create Trip Collection. One existing
collection with the same normalized name is returned without another copy. If
several existing collections match, ask which one the person means or request a
different new name. Never delete a collection to resolve ambiguity or capacity.

Use Rename Trip Collection for a requested title change. The collection keeps its
identity and saved places; it does not merge with another similarly named list.

Use Save Trip Place to Collection for an exact existing itinerary place. It copies
the place into the chosen collection, leaves the original visit in its day, and
does not copy visit timing or private notes. Repeating the same save keeps one copy.
This action cannot import a booking or an arbitrary generated place. For a new
place, Find a Place for My Trip opens the existing MapKit search and requires the
person to select a real result before saving it.

Use Schedule Collection Place on Day to add an exact saved collection place to an
existing day in the same trip. Resolve the place, its collection, and its trip;
ask when names are ambiguous. Keep the collection unchanged. Repeating the action
returns the existing visit on that day without replacing its notes or timing.
The action copies the place only, not private notes or timing, and makes no booking.
Use the returned saved visit for further requested timing edits or directions.
Do not move an existing visit when the person only asked to add a shortlist place.

After requested edits, use the returned canonical result or Read Trip Collection
to describe the saved result. If saving fails, explain the returned recovery step;
do not say the shortlist was saved. Moving a scheduled place to another day is a
separate task handled by Move Saved Place to Day.
