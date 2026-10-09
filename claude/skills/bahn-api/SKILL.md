---
name: bahn-api
description: Query real DB connections and Sparpreis prices from the bahn.de Vendo API, no key and no login. Use when planning a train trip, comparing routes or travel dates, checking what a Deutschlandticket covers, or whenever a Deutsche Bahn fare needs a real number instead of a guess.
---

# Bahn API

`bahn.py` in this directory talks to the undocumented API behind bahn.de. No key, no
login, no rate limit hit so far. Use it instead of guessing fares or sending the user
to the Navigator.

```bash
./bahn.py Flensburg "München Hbf" 2026-09-22 --time 07:00 --bc25 --ages 29,25
./bahn.py Kehl "Stuttgart Hbf" 2026-09-28 --regional      # Deutschlandticket-valid only
./bahn.py Strasbourg "Stuttgart Hbf" 2026-09-27 -v        # every leg and transfer gap
./bahn.py --selfcheck                                     # invariants still hold
```

**Always pass `--ages`, never `--persons`, once you know how old the travellers are.**
Anyone under 27 gets Sparpreis Junge Leute on top of any BahnCard — worth about 22% —
and the API only grants it when `alter` is filled in. `--persons 2` silently quotes two
full adults. Ask for ages if they have not been mentioned.

`--json` for further processing. Import `resolve`, `journeys`, `parse` to script sweeps
over many dates — that is the normal case, one call per date, and it is fast enough to
brute-force a week.

## The traps

**The price is the total for the whole party, not per person.** Two travellers return
double. Doubling it again is the one mistake that has actually shipped a wrong answer
here. `--selfcheck` asserts the invariant against the live API.

**A missing age is a silent overcharge.** No `alter` means adult fare, no error. See
the age note above.

**Answers arrive gzipped no matter what `Accept-Encoding` says.** The script sniffs the
magic bytes. Anything reimplementing this must too.

**A 422 comes back with an empty body.** It is a body-shape error, and the fields that
cause it are `alter: []` inside `reisende` plus `deutschlandTicketVorhanden` and
`nurDeutschlandTicketVerbindungen`. Omit any of the three and the request dies silently.

**Sparpreise are contingents, not prices.** Everything quoted is what is left today.
Say so when handing numbers to a user, and name which legs are the thin ones.

## Reading results

| Field | Holds |
|---|---|
| `angebotsPreis.betrag` | Cheapest offer, party total, `None` if none is bookable |
| `verbindungsDauerInSeconds` | Door-to-door for the whole connection |
| `umstiegsAnzahl` | Excludes station footpaths, which still eat 12 min at Stuttgart Hbf |
| `abfahrt.sollzeit` | Scheduled, ISO. There is no `abfahrtsZeitpunkt` at connection level |

Local transport legs — U-Bahn, tram, city bus — are routed and shown but **not** covered
by the fare quoted. Treat them as a separate ticket.

## What actually moves money

Check these before optimising anything else. Each one has been worth more than route
geometry on a real trip.

**The same train costs different amounts by direction and weekday.** Strasbourg→Stuttgart
was 55,35 on a Sunday evening and 30,33 on the Monday, same ICE, same minute. Sunday
evening and Sunday afternoon are return peaks; the day after a holiday is cheap. Sweep
the dates rather than reasoning about them.

**When a trip visits three cities, price both orderings.** Which expensive leg you pay
depends on the order, and the swing came to 74 € on a four-leg trip — far more than the
detour distance suggests.

**`--regional` is the Deutschlandticket check.** If a connection survives the filter, a
D-Ticket covers it end to end, and it carries no Zugbindung, so a missed connection costs
time instead of money. A short cross-border walk or tram into the nearest German station
can turn an expensive international leg into a free one. Verify the whole chain with the
filter — routers slip an IC into an otherwise regional itinerary and break coverage.

**A daytime regional chain is a different risk from the same chain at night.** Hourly
service means a missed connection costs an hour; after 22:00 it can mean a 01:30 arrival
or a taxi. Price and risk have to be quoted together.

## How to present a plan

**Give two or three options per travel day, not one.** The cheapest departure is often
the one nobody wants to take. Show the trade-off and let the user pick:

```
Di 22.09  Flensburg -> Ostfildern
  05:17 -> 13:04   7:47h  2x   39,00     billigste, aber Aufstehen um 4
  07:17 -> 15:04   7:47h  2x   47,00
  09:17 -> 17:10   7:53h  2x   51,00     normaler Morgen, +12 EUR
```

Name what the extra money buys — a normal wake-up, one change fewer, an hour more in the
city — and say which one you would take and why. On a day that is nothing but travel and
is followed by spare days at the destination, the civilised departure usually wins over
the cheapest one; on a day that eats into limited time at a destination, the early train
usually wins. State that reasoning rather than assuming it.

**Ask instead of guessing.** When assembling a full multi-city plan, stop and ask as
soon as an answer would change the itinerary rather than just the wording: whether an
extra night is worth a cheaper long leg, how late an arrival is still acceptable, whether
a free day before or after an appointment is worth more, how firm a return date is. One
batched round of questions beats a plan built on an assumption that turns out wrong.
Anything you did not ask about, state as an explicit assumption next to the number.

## Niklas's rule on Deutschlandticket legs

Never use the D-Ticket for a leg that feeds a train-bound ticket. If the regional feeder
fails, there is no Fahrgastrechte claim on a later ICE. Book such a leg inside the through
ticket even when the D-Ticket would cover it.

It is fine where nothing bound follows: the last stretch home, local transport to the
station, or a leg with no realistic alternative to lose. The test is what comes after,
not where the leg sits in the journey.
