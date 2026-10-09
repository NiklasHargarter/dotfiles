#!/usr/bin/env python3
"""Query the bahn.de Vendo API for connections and Sparpreis prices.

  bahn.py Flensburg "München Hbf" 2026-09-22 --time 07:00 --bc25 --ages 29,25
  bahn.py Kehl "Stuttgart Hbf" 2026-09-28 --regional     # D-Ticket-valid only
  bahn.py --selfcheck

No API key. Prices are the total for the whole party, not per person.
"""
import argparse
import gzip
import json
import sys
import urllib.parse
import urllib.request

BASE = "https://int.bahn.de/web/api"
HDR = {
    "Content-Type": "application/json; charset=utf-8",
    "Accept": "application/json",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                  "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36",
    "Origin": "https://int.bahn.de",
    "Referer": "https://int.bahn.de/",
}

ALL_PRODUCTS = ["ICE", "EC_IC", "IR", "REGIONAL", "SBAHN", "BUS",
                "SCHIFF", "UBAHN", "TRAM", "ANRUFPFLICHTIG"]
# Deutschlandticket covers Nahverkehr only — no ICE/IC/EC/IR.
REGIONAL_PRODUCTS = ["REGIONAL", "SBAHN", "BUS", "UBAHN", "TRAM",
                     "SCHIFF", "ANRUFPFLICHTIG"]


def _fetch(url, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers=HDR,
                                 method="POST" if data else "GET")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            raw = r.read()
    except urllib.error.HTTPError as e:
        # 422 means the body shape is wrong; the response carries no detail.
        sys.exit(f"HTTP {e.code} from {url}\n{e.read().decode()[:500]}")
    # Sent regardless of Accept-Encoding.
    if raw[:2] == b"\x1f\x8b":
        raw = gzip.decompress(raw)
    return json.loads(raw)


def resolve(name):
    """Station name -> the opaque location id the journey endpoint needs."""
    q = urllib.parse.urlencode({"suchbegriff": name, "typ": "ALL", "limit": 1})
    hits = _fetch(f"{BASE}/reiseloesung/orte?{q}")
    if not hits:
        sys.exit(f"no station found for {name!r}")
    return hits[0]["id"], hits[0]["name"]


def _reisende(persons, ages, erm):
    """One entry per traveller. Age matters: under 27 gets Sparpreis Junge Leute,
    roughly 22% off on top of a BahnCard, and it is only applied if `alter` is set."""
    if not ages:
        return [{"typ": "ERWACHSENER", "ermaessigungen": [erm],
                 "alter": [], "anzahl": persons}]
    return [{"typ": "KIND" if a < 15 else "JUGENDLICHER" if a < 27 else "ERWACHSENER",
             "ermaessigungen": [erm], "alter": [str(a)], "anzahl": 1} for a in ages]


def journeys(origin, destination, when, persons=1, discount=None,
             first_class=False, regional_only=False, arrival=False, ages=None):
    klasse = "KLASSE_1" if first_class else "KLASSE_2"
    erm = ({"art": discount, "klasse": klasse} if discount
           else {"art": "KEINE_ERMAESSIGUNG", "klasse": "KLASSENLOS"})
    body = {
        "abfahrtsHalt": origin,
        "ankunftsHalt": destination,
        "anfrageZeitpunkt": when,
        "ankunftSuche": "ANKUNFT" if arrival else "ABFAHRT",
        "klasse": klasse,
        "produktgattungen": REGIONAL_PRODUCTS if regional_only else ALL_PRODUCTS,
        # "alter" and the two Deutschlandticket flags are required; without
        # them the endpoint answers 422 with an empty body.
        "reisende": _reisende(persons, ages, erm),
        "schnelleVerbindungen": True,
        "sitzplatzOnly": False,
        "bikeCarriage": False,
        "reservierungsKontingenteVorhanden": False,
        "deutschlandTicketVorhanden": False,
        "nurDeutschlandTicketVerbindungen": False,
    }
    return _fetch(f"{BASE}/angebote/fahrplan", body)


def parse(result):
    out = []
    for v in result.get("verbindungen", []):
        v = v.get("verbindung", v)
        segs = v["verbindungsAbschnitte"]
        legs = []
        for s in segs:
            vm = s.get("verkehrsmittel", {})
            legs.append({
                "name": vm.get("mittelText") or vm.get("name") or "Fußweg",
                "dep": s["abfahrt"]["sollzeit"],
                "arr": s["ankunft"]["sollzeit"],
                "from": s["abfahrtsOrt"],
                "to": s["ankunftsOrt"],
            })
        out.append({
            "dep": segs[0]["abfahrt"]["sollzeit"],
            "arr": segs[-1]["ankunft"]["sollzeit"],
            "seconds": v.get("verbindungsDauerInSeconds", 0),
            "changes": v.get("umstiegsAnzahl"),
            # Total for the whole party. Not per person.
            "price": (v.get("angebotsPreis") or {}).get("betrag"),
            "legs": legs,
        })
    return out


def show(trips, verbose=False):
    for t in trips:
        d, price = t["seconds"], t["price"]
        overnight = " +1d" if t["dep"][:10] != t["arr"][:10] else ""
        print(f"{t['dep'][:10]} {t['dep'][11:16]}->{t['arr'][11:16]}{overnight}  "
              f"{d // 3600}:{(d % 3600) // 60:02d}h  {t['changes']}x  "
              f"{f'{price:.2f} EUR' if price else '    -    '}")
        if verbose:
            prev = None
            for leg in t["legs"]:
                if prev:
                    gap = ((int(leg["dep"][11:13]) * 60 + int(leg["dep"][14:16]))
                           - (int(prev[11:13]) * 60 + int(prev[14:16]))) % 1440
                    print(f"        [{gap} min Umstieg]")
                print(f"   {leg['dep'][11:16]}-{leg['arr'][11:16]}  "
                      f"{leg['name']:<18} {leg['from']} -> {leg['to']}")
                prev = leg["arr"]
            print()


def selfcheck():
    """The price field is a party total. Getting this wrong doubles every quote."""
    origin, _ = resolve("Hamburg Hbf")
    dest, _ = resolve("Berlin Hbf")
    when = "2026-09-22T09:00:00"
    one = parse(journeys(origin, dest, when, persons=1))
    two = parse(journeys(origin, dest, when, persons=2))
    pairs = [(a["price"], b["price"]) for a, b in zip(one, two)
             if a["price"] and b["price"]]
    assert pairs, "no priced connections returned — API shape may have changed"
    for single, double in pairs:
        assert abs(double - 2 * single) < 0.01, (
            f"price is not a party total: 1 person {single}, 2 persons {double}")
    print(f"ok — price is the party total ({len(pairs)} connections checked)")

    # A traveller under 27 must come out cheaper than the same traveller as an adult,
    # and a mixed party must be the exact sum of its members.
    adult = parse(journeys(origin, dest, when, ages=[40]))
    young = parse(journeys(origin, dest, when, ages=[25]))
    mixed = parse(journeys(origin, dest, when, ages=[40, 25]))
    trio = [(a["price"], y["price"], m["price"])
            for a, y, m in zip(adult, young, mixed) if a["price"] and y["price"] and m["price"]]
    assert trio, "no priced connections for the age check"
    for a, y, m in trio:
        assert y < a, f"age 25 not cheaper than adult: {y} vs {a}"
        assert abs(m - (a + y)) < 0.01, f"mixed party {m} != {a} + {y}"
    print(f"ok — under-27 fare applies and mixed parties sum ({len(trio)} checked)")


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("origin", nargs="?")
    p.add_argument("destination", nargs="?")
    p.add_argument("date", nargs="?", help="YYYY-MM-DD")
    p.add_argument("--time", default="08:00")
    p.add_argument("--arrival", action="store_true", help="date/time is arrival, not departure")
    p.add_argument("--persons", type=int, default=1)
    p.add_argument("--ages", help="comma-separated ages, e.g. 29,25 — under 27 fares are cheaper")
    p.add_argument("--bc25", action="store_const", const="BAHNCARD25", dest="discount")
    p.add_argument("--bc50", action="store_const", const="BAHNCARD50", dest="discount")
    p.add_argument("--first", action="store_true", help="1st class")
    p.add_argument("--regional", action="store_true",
                   help="Nahverkehr only — what a Deutschlandticket actually covers")
    p.add_argument("--verbose", "-v", action="store_true", help="show every leg and transfer")
    p.add_argument("--json", action="store_true")
    p.add_argument("--selfcheck", action="store_true")
    a = p.parse_args()

    if a.selfcheck:
        return selfcheck()
    if not (a.origin and a.destination and a.date):
        p.error("origin, destination and date are required")

    ages = [int(x) for x in a.ages.split(",")] if a.ages else None
    origin, oname = resolve(a.origin)
    dest, dname = resolve(a.destination)
    trips = parse(journeys(origin, dest, f"{a.date}T{a.time}:00",
                           persons=a.persons, discount=a.discount,
                           first_class=a.first, regional_only=a.regional,
                           arrival=a.arrival, ages=ages))
    if a.json:
        print(json.dumps(trips, ensure_ascii=False, indent=2))
        return
    who = (f"Alter {a.ages}" if ages else f"{a.persons} Pers")
    who += f", {a.discount}" if a.discount else ""
    print(f"{oname} -> {dname}, {a.date} ({who}, price = party total)")
    show(trips, verbose=a.verbose)


if __name__ == "__main__":
    main()
