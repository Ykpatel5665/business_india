# Monopoly Rules Reference (Authoritative)

This document is the source-of-truth reference for the standard US Hasbro/Parker Brothers edition of Monopoly. Values, card texts, and rules below match the official rulebook. Where the written rules are ambiguous or commonly replaced by house rules, this is called out explicitly with the label **[AMBIGUITY]** or **[HOUSE RULE]**.

---

## 1. Game Overview & Winning Condition

Monopoly is a turn-based property-trading game for 2 to 8 players. Players move tokens around a 40-square board based on two-dice rolls, buying, trading, and developing properties, collecting rent from opponents, and trying to bankrupt them.

**Winning condition:** The last solvent (non-bankrupt) player wins. The game ends the moment the second-to-last player is declared bankrupt. There is no alternative time-limited or points-based win condition in the official rules (a shorter "time-limit" variant exists as an optional rule, but it is not the default).

---

## 2. Setup

- **Player count:** 2 to 8.
- **Starting position:** All tokens start on GO (board index 0).
- **Starting money:** Each player receives **$1,500**, distributed in this exact denomination breakdown:
  - 2 x $500
  - 2 x $100
  - 2 x $50
  - 6 x $20
  - 5 x $10
  - 5 x $5
  - 5 x $1
  - Total: $1,500
- **Banker:** One player is chosen as the Banker. The Banker may also play. The Banker manages the bank's money, unowned title deeds, houses, hotels, and handles auctions, rent from the bank (GO salary, card payouts), and loans/mortgages. The Bank never "goes bankrupt"; if it runs out of cash, it may issue as much as needed on scrap paper. The Bank has a **limited supply** of 32 houses and 12 hotels — this limit IS enforced (see Section 10).
- **Title deeds:** Held by the Bank until purchased.
- **Dice:** Two six-sided dice.
- **Cards:** 16 Chance cards and 16 Community Chest cards, shuffled and placed face-down on their respective board spaces.

---

## 3. Board Layout

The board has 40 squares indexed 0-39, traversed clockwise. Prices and rents below are from the standard US edition.

**House cost per color group** (cost per house AND per hotel upgrade step):
- Brown, Light Blue: **$50**
- Pink, Orange: **$100**
- Red, Yellow: **$150**
- Green, Dark Blue: **$200**

A hotel costs the same as one additional house on top of 4 houses (i.e., 4 houses + house-cost = hotel), and the 4 houses are returned to the Bank.

Rent table legend: **Base** = unimproved, single-owned. **Mono** = unimproved but owner has full color group (base x 2). **1H/2H/3H/4H** = with that many houses. **Hot** = with hotel. **Mort** = mortgage value (always half of purchase price, rounded).

### South side (bottom row)

| Idx | Name | Type | Price | Mort | Base | Mono | 1H | 2H | 3H | 4H | Hot |
|----|------|------|-------|------|------|------|------|------|------|------|------|
| 0 | GO | Corner | - | - | - | - | - | - | - | - | - |
| 1 | Mediterranean Avenue | Brown | 60 | 30 | 2 | 4 | 10 | 30 | 90 | 160 | 250 |
| 2 | Community Chest | Card | - | - | - | - | - | - | - | - | - |
| 3 | Baltic Avenue | Brown | 60 | 30 | 4 | 8 | 20 | 60 | 180 | 320 | 450 |
| 4 | Income Tax | Tax | - | - | pay $200 | - | - | - | - | - | - |
| 5 | Reading Railroad | RR | 200 | 100 | 25 | - | - | - | - | - | - |
| 6 | Oriental Avenue | Lt Blue | 100 | 50 | 6 | 12 | 30 | 90 | 270 | 400 | 550 |
| 7 | Chance | Card | - | - | - | - | - | - | - | - | - |
| 8 | Vermont Avenue | Lt Blue | 100 | 50 | 6 | 12 | 30 | 90 | 270 | 400 | 550 |
| 9 | Connecticut Avenue | Lt Blue | 120 | 60 | 8 | 16 | 40 | 100 | 300 | 450 | 600 |

### West side

| Idx | Name | Type | Price | Mort | Base | Mono | 1H | 2H | 3H | 4H | Hot |
|----|------|------|-------|------|------|------|------|------|------|------|------|
| 10 | Jail / Just Visiting | Corner | - | - | - | - | - | - | - | - | - |
| 11 | St. Charles Place | Pink | 140 | 70 | 10 | 20 | 50 | 150 | 450 | 625 | 750 |
| 12 | Electric Company | Util | 150 | 75 | (see rent) | - | - | - | - | - | - |
| 13 | States Avenue | Pink | 140 | 70 | 10 | 20 | 50 | 150 | 450 | 625 | 750 |
| 14 | Virginia Avenue | Pink | 160 | 80 | 12 | 24 | 60 | 180 | 500 | 700 | 900 |
| 15 | Pennsylvania Railroad | RR | 200 | 100 | 25 | - | - | - | - | - | - |
| 16 | St. James Place | Orange | 180 | 90 | 14 | 28 | 70 | 200 | 550 | 750 | 950 |
| 17 | Community Chest | Card | - | - | - | - | - | - | - | - | - |
| 18 | Tennessee Avenue | Orange | 180 | 90 | 14 | 28 | 70 | 200 | 550 | 750 | 950 |
| 19 | New York Avenue | Orange | 200 | 100 | 16 | 32 | 80 | 220 | 600 | 800 | 1000 |

### North side (top row)

| Idx | Name | Type | Price | Mort | Base | Mono | 1H | 2H | 3H | 4H | Hot |
|----|------|------|-------|------|------|------|------|------|------|------|------|
| 20 | Free Parking | Corner | - | - | - | - | - | - | - | - | - |
| 21 | Kentucky Avenue | Red | 220 | 110 | 18 | 36 | 90 | 250 | 700 | 875 | 1050 |
| 22 | Chance | Card | - | - | - | - | - | - | - | - | - |
| 23 | Indiana Avenue | Red | 220 | 110 | 18 | 36 | 90 | 250 | 700 | 875 | 1050 |
| 24 | Illinois Avenue | Red | 240 | 120 | 20 | 40 | 100 | 300 | 750 | 925 | 1100 |
| 25 | B. & O. Railroad | RR | 200 | 100 | 25 | - | - | - | - | - | - |
| 26 | Atlantic Avenue | Yellow | 260 | 130 | 22 | 44 | 110 | 330 | 800 | 975 | 1150 |
| 27 | Ventnor Avenue | Yellow | 260 | 130 | 22 | 44 | 110 | 330 | 800 | 975 | 1150 |
| 28 | Water Works | Util | 150 | 75 | (see rent) | - | - | - | - | - | - |
| 29 | Marvin Gardens | Yellow | 280 | 140 | 24 | 48 | 120 | 360 | 850 | 1025 | 1200 |

### East side

| Idx | Name | Type | Price | Mort | Base | Mono | 1H | 2H | 3H | 4H | Hot |
|----|------|------|-------|------|------|------|------|------|------|------|------|
| 30 | Go To Jail | Corner | - | - | - | - | - | - | - | - | - |
| 31 | Pacific Avenue | Green | 300 | 150 | 26 | 52 | 130 | 390 | 900 | 1100 | 1275 |
| 32 | North Carolina Avenue | Green | 300 | 150 | 26 | 52 | 130 | 390 | 900 | 1100 | 1275 |
| 33 | Community Chest | Card | - | - | - | - | - | - | - | - | - |
| 34 | Pennsylvania Avenue | Green | 320 | 160 | 28 | 56 | 150 | 450 | 1000 | 1200 | 1400 |
| 35 | Short Line | RR | 200 | 100 | 25 | - | - | - | - | - | - |
| 36 | Chance | Card | - | - | - | - | - | - | - | - | - |
| 37 | Park Place | Dk Blue | 350 | 175 | 35 | 70 | 175 | 500 | 1100 | 1300 | 1500 |
| 38 | Luxury Tax | Tax | - | - | pay $100 | - | - | - | - | - | - |
| 39 | Boardwalk | Dk Blue | 400 | 200 | 50 | 100 | 200 | 600 | 1400 | 1700 | 2000 |

**Railroads:** 4 total (indices 5, 15, 25, 35). Price $200, mortgage $100. Rent scales by count owned: 1 = $25, 2 = $50, 3 = $100, 4 = $200.

**Utilities:** 2 total (indices 12, 28). Price $150, mortgage $75. See rent formula in Section 9.

**Taxes:**
- Income Tax (idx 4): Pay **$200** (flat). The older rule "10% of all assets OR $200, player's choice" was removed in post-2008 rules; modern editions are flat $200. **[AMBIGUITY]** across editions.
- Luxury Tax (idx 38): Pay **$100** (older editions $75 — this is $100 in current rules). **[AMBIGUITY]**.

**Card squares:** Chance = indices 7, 22, 36. Community Chest = indices 2, 17, 33.

---

## 4. Turn Sequence

On each turn, in strict order:

1. **Pre-roll actions (optional):** Build houses/hotels on owned monopolies, mortgage or unmortgage properties, propose trades, sell buildings back to bank. Pay $50 to leave Jail (if in Jail) before rolling, or play Get Out of Jail Free card.
2. **Roll** two dice.
3. **Move** token clockwise by the sum of the dice.
4. **Land action** — resolve the square (buy/pay rent/draw card/etc.). See Section 6.
5. **Post-move actions (optional):** Same list as pre-roll — build, mortgage, trade, sell buildings.
6. **If doubles were rolled and not sent to Jail**, take another turn (same sequence) after resolving the current one.
7. **End turn:** pass dice to the next player.

Trading, building, mortgaging, and selling buildings may happen at essentially any time except mid-move/mid-rent-settlement. In practice, the rules say these may be done "on any player's turn" — **[AMBIGUITY]**: Hasbro FAQ has clarified that while the rulebook says trades can happen "at any time," strict play restricts non-owner actions (like building/mortgaging) to the owner's own turn. Most implementations limit building/mortgaging to the owner's turn and allow trades between any two players on the current player's turn.

---

## 5. Dice & Doubles

- Roll two dice; sum = movement.
- If the roll is **doubles**, after finishing the landing action, the player rolls again.
- If a player rolls doubles **three times in a single turn**, on the third double they **do NOT move**. Instead they immediately **Go To Jail** (do not pass GO, do not collect $200). This is a hard rule.
- Rolling doubles while already in Jail does NOT count toward the 3-doubles-to-jail rule; instead it releases the player (see Section 11) and they move by the doubles roll. They do NOT get another roll after doubles-release from Jail.

---

## 6. Landing Actions

- **GO (0):** Collect $200 when passing OR landing. (Older editions had a "double salary if landing" house rule — NOT official.)
- **Property (color, RR, Utility):** If unowned → buy at list price OR trigger auction (Section 8). If owned by another player and not mortgaged → pay rent. If owned by self or mortgaged → nothing.
- **Chance / Community Chest (2,7,17,22,33,36):** Draw top card, follow instructions, return to bottom of deck (except Get Out of Jail Free, kept by player).
- **Income Tax (4):** Pay $200 to Bank.
- **Luxury Tax (38):** Pay $100 to Bank.
- **Free Parking (20):** Nothing happens. Officially no money is collected.
- **Jail / Just Visiting (10):** If passing through / landing while not arrested, nothing. Token is placed on "Just Visiting" portion.
- **Go To Jail (30):** Move directly to Jail (idx 10, in-jail side). Do not pass GO, do not collect $200. Turn ends immediately — even if arrived by doubles, no re-roll.

---

## 7. Buying Property

When landing on an unowned deed, RR, or utility, the player may buy it **from the Bank at the listed price printed on the title deed**. Price is fixed; no negotiation with Bank. Player receives the title deed card immediately.

Players may only buy directly from the Bank when landing on the property. Buying unowned property from the Bank at other times is NOT allowed — the only way unowned properties change hands outside of landing is via auction.

---

## 8. Mandatory Auction Rule

If a player lands on an unowned property and **declines to buy it at list price**, the Bank MUST immediately **auction** the property to **all players, including the player who declined**. This rule is NOT optional and is the most commonly house-ruled-away part of Monopoly.

Auction procedure:
- Any player may open bidding at any amount, with **$1 as the minimum bid** (officially the minimum is "any amount" with $1 as the typical floor).
- Bids proceed openly until no higher bid is offered.
- Highest bidder pays the Bank the bid amount and takes the title deed.
- If no player bids anything, the property remains with the Bank (unowned).
- The original decliner may bid and may win, paying potentially less than list price.

---

## 9. Rent Calculation

Rent is only owed if the owner's property is **not mortgaged**. Mortgaged properties collect no rent. Utilities and railroads collect no rent if mortgaged even if the owner holds others in the set.

### Color properties

- Base rent if owner does not have all properties of that color group.
- If owner has **full color group** (monopoly) AND **no houses built on any property in the group**: rent is **2 x base** (doubled unimproved rent).
- If houses or a hotel are present on that specific property: use the house/hotel rent from the title deed card (which already assumes monopoly ownership).

### Railroads

Rent depends on how many railroads the owner holds (even if some are mortgaged, they still count for determining rent tier on the UN-mortgaged ones — **[AMBIGUITY]**: some rule editions say mortgaged RRs do NOT count for tier-counting; most modern rulebooks say they still count. Strict reading: mortgaged RRs still count toward the "how many owned" tier).
- 1 owned: $25
- 2 owned: $50
- 3 owned: $100
- 4 owned: $200

### Utilities

Rent is based on the dice roll that landed the opponent there:
- If owner has 1 utility: rent = **4 x dice roll**
- If owner has both utilities: rent = **10 x dice roll**

Special case: if the player arrived via a Chance card "Advance to nearest Utility" card, the card specifies the player rolls dice again and pays **10x** regardless of how many the owner holds (see Section 12).

### Rent-demand rule

Rent **must be demanded by the owner before the next player rolls the dice**. If the owner forgets, the rent is forfeit. This is an official rule and frequently ignored in casual play.

---

## 10. Houses & Hotels

**Prerequisites to build:**
- Player must own all properties of the color group (monopoly).
- No property in that color group may be mortgaged.
- Houses must be bought from the Bank at the house-cost for that group (Section 3).

**Even-build rule (mandatory):** Houses must be distributed across the color group such that the **difference in house count between any two properties of the group is at most 1**. You cannot put a 2nd house on one property until every property in the group has at least 1. The same rule applies to selling houses back — you must sell evenly.

**Hotels:**
- A property is upgraded to a hotel after having **4 houses**, by paying the house cost one more time AND returning the 4 houses to the Bank.
- Only **1 hotel per property**; no "skyscrapers" officially.
- To upgrade to hotel, every property in that monopoly must have 4 houses first (because of even-build).

**Supply limits (officially enforced):**
- 32 houses total in the Bank.
- 12 hotels total.
- If there are not enough houses for all players who want them, the Bank holds a **single auction for each available house**: highest bidder wins the right to buy at auction price (but the official rule is the auction price is paid in addition to, or instead of, the list price depending on edition — **[AMBIGUITY]**: modern rule = highest bidder pays the auction amount to the Bank for the house). This rule is almost always ignored by casual players and is the basis of tournament-level strategy (the "housing shortage" strategy).
- Hotels cannot be "downgraded" to 4 houses if there are fewer than 4 houses available in the Bank — in that case, the Bank auctions the hotel-to-houses swap per the shortage rule.

**Selling back:** Houses and hotels are sold back to the Bank at **half the purchase price**. A hotel sells as 5x the per-house cost / 2 (i.e., half the cost of 5 houses' worth). Even-sell rule applies.

**Timing of building:** Officially, building may happen on any turn, including (per rulebook) "even on another player's turn, or between turns." **[AMBIGUITY]**: Hasbro's rulebook literally permits mid-opponent-turn building; most implementations restrict building to the owner's own turn for simplicity.

---

## 11. Jail

**Entry methods (3):**
1. Landing on "Go To Jail" (idx 30).
2. Drawing a "Go to Jail" card from Chance or Community Chest.
3. Rolling **3 consecutive doubles** in one turn.

In all 3 cases, the player moves directly to Jail (idx 10), does NOT pass GO, does NOT collect $200, and their turn ends immediately.

**While in Jail, the player CAN still:**
- Collect rent from opponents.
- Trade properties and cash.
- Mortgage / unmortgage.
- Buy / sell houses and hotels.
- Play Get Out of Jail Free card.

**Exit methods (3):**
1. **Pay $50** to the Bank before rolling, then roll and move normally.
2. **Use a Get Out of Jail Free card** (from either deck); discard the card to the bottom of its deck. Then roll and move normally.
3. **Roll doubles.** Up to 3 attempts allowed, one per turn:
   - If doubles on any attempt: exit Jail and move that doubles amount. Do **NOT** take another turn despite rolling doubles.
   - If no doubles on the 3rd attempt: player **must pay $50** to the Bank, then move according to the 3rd roll's dice sum. (Player does not stay in Jail a 4th turn.)

A player may NOT refuse to pay and stay indefinitely; after 3 failed doubles attempts, paying is mandatory.

---

## 12. Chance (16 cards)

Exact official card texts (US edition):

1. **Advance to GO.** Collect $200.
2. **Advance to Illinois Avenue.** If you pass GO, collect $200.
3. **Advance to St. Charles Place.** If you pass GO, collect $200.
4. **Advance token to the nearest Utility.** If unowned, you may buy it from the Bank. If owned, throw dice and pay owner **10 times** the amount thrown (regardless of how many utilities owner has).
5. **Advance token to the nearest Railroad.** If unowned, you may buy it. If owned, pay owner **twice the rental** to which they would otherwise be entitled. (If no one owns it, normal buy/auction rule applies.)
6. **Advance token to the nearest Railroad.** Same effect as #5. (Two such cards exist in the deck.)
7. **Bank pays you dividend of $50.**
8. **Get Out of Jail Free.** This card may be kept until needed or sold/traded.
9. **Go back 3 spaces.**
10. **Go to Jail.** Go directly to Jail. Do not pass GO, do not collect $200.
11. **Make general repairs on all your property.** For each house pay $25; for each hotel pay $100.
12. **Speeding fine $15.** Pay $15.
13. **Take a trip to Reading Railroad.** If you pass GO, collect $200.
14. **Take a walk on the Boardwalk.** Advance token to Boardwalk.
15. **You have been elected Chairman of the Board.** Pay each player $50.
16. **Your building loan matures.** Collect $150.

Note: two "Advance to nearest Railroad" cards exist in the Chance deck (cards 5 and 6 above).

---

## 13. Community Chest (16 cards)

Exact official card texts (US edition):

1. **Advance to GO.** Collect $200.
2. **Bank error in your favor.** Collect $200.
3. **Doctor's fee.** Pay $50.
4. **From sale of stock you get $50.**
5. **Get Out of Jail Free.** This card may be kept until needed or sold/traded.
6. **Go to Jail.** Go directly to Jail. Do not pass GO, do not collect $200.
7. **Holiday fund matures.** Receive $100.
8. **Income tax refund.** Collect $20.
9. **It is your birthday.** Collect $10 from every player.
10. **Life insurance matures.** Collect $100.
11. **Hospital fees.** Pay $100.
12. **School fees.** Pay $50.
13. **Receive $25 consultancy fee.**
14. **You are assessed for street repair.** Pay $40 per house and $115 per hotel you own.
15. **You have won second prize in a beauty contest.** Collect $10.
16. **You inherit $100.**

---

## 14. Mortgage

- **Mortgage value** is printed on each title deed; for all properties it equals **half the purchase price**.
- A property may only be mortgaged if there are **no houses** on any property in its color group. Houses must be sold back to the Bank first (at half price).
- While mortgaged: the property collects **no rent**. For railroads and utilities, a mortgaged property does not earn rent but still counts for the "how many owned" tier per most rule editions. **[AMBIGUITY]** above.
- **Unmortgaging:** pay the Bank mortgage value + 10% interest (always round up). E.g., a $100 mortgage costs $110 to clear.
- **Transfer of mortgaged property via trade:** When a mortgaged property is traded, the new owner has a choice:
  - **Option A:** Pay the Bank **10% interest immediately** (a fee paid just to take ownership while keeping it mortgaged). Then, later, when they want to unmortgage, they must pay **mortgage value + another 10%**. So total cost if they eventually unmortgage = mortgage + 20%.
  - **Option B:** **Unmortgage immediately**: pay the Bank the mortgage value + 10% interest at time of transfer.

---

## 15. Trading

**Tradable assets:**
- Cash
- Title deeds (properties, railroads, utilities) — whether mortgaged or unmortgaged.
- Get Out of Jail Free cards (yes, these are tradable officially).

**NOT tradable:**
- Houses and hotels. They cannot be moved between players or properties. To "transfer" developments, the owner must first sell them back to the Bank at half price, then trade the bare deeds, and the new owner may re-build if they hold the monopoly.

**Trading rules:**
- Trades occur between exactly **two players** at a time.
- Trades may include any mix of the above assets and in any ratio agreed between the two players (including wildly unequal trades — the game permits "gifts").
- Mortgaged properties carry the mortgage obligation; new owner pays 10% fee or unmortgages (see Section 14).
- **[AMBIGUITY]**: The rulebook says trading can happen "any time," but most strict readings and tournament play restrict trades to occurring during the active player's turn and when no other action (mid-roll, mid-rent-settlement, mid-auction) is pending.

---

## 16. Bankruptcy

A player is bankrupt when they owe more money than they can raise by selling buildings, mortgaging properties, and from cash on hand. Bankruptcy is mandatory — the player cannot "refuse to pay."

Before declaring bankruptcy, a player must attempt to raise funds: sell buildings to Bank at half price, mortgage properties, and may trade (though in practice no trades once bankruptcy is declared).

### 16a. Bankruptcy to another player

If the debt is owed to another player (rent, card payment between players, etc.):
- **All cash** on hand transfers to the creditor.
- **All properties (mortgaged and unmortgaged)** transfer to the creditor.
- **All Get Out of Jail Free cards** transfer to the creditor.
- Any houses/hotels owned by the bankrupt player must first be sold back to the Bank at half price — they cannot be transferred to the creditor directly.
- **Mortgaged properties:** creditor must immediately either pay the Bank 10% interest to keep them mortgaged, OR pay mortgage value + 10% to unmortgage them (same rule as trade transfer).
- The bankrupt player is removed from the game.

### 16b. Bankruptcy to the Bank

If the debt is owed to the Bank (tax, Chance/CC payment, unpaid rent in certain edge cases):
- All cash transfers to the Bank.
- All houses/hotels are sold back to the Bank at half price.
- **All properties (including mortgaged) are returned to the Bank, and the Bank must immediately AUCTION each property one by one** to the remaining players. Auction rules per Section 8.
- All Get Out of Jail Free cards are returned to the bottom of their respective decks.
- The bankrupt player is removed from the game.

---

## 17. Endgame

The game ends immediately when **only one solvent player remains**. That player is declared the winner. There is no score-counting, no net-worth comparison — survivorship is the sole criterion.

An optional "short game" variant with a fixed time limit, where the winner is whoever has the highest total net worth (cash + property value + mortgage value of mortgaged + house/hotel cost), exists in the rulebook as an appendix, but is NOT the default rule.

---

## 18. Official Rule Clarifications

These are the most commonly misunderstood rules, explicitly stated:

- **Free Parking (idx 20) = nothing.** No money is collected when landing here. The popular "Free Parking jackpot" (taxes and fees accumulate there, winner collects upon landing) is a **[HOUSE RULE]** not in the official rulebook.
- **Taxes do NOT go to Free Parking.** Income Tax and Luxury Tax payments go directly to the Bank.
- **Rent must be demanded before the next player rolls** — if the owner forgets, rent is forfeit. Official but often ignored.
- **Auctions are mandatory** if a player declines to buy. Most casual games skip auctions; this is a **[HOUSE RULE]**.
- **Housing shortage rule:** When the Bank's supply of 32 houses runs low and multiple players want to build, the Bank auctions each available house to the highest bidder. Few implementations enforce this.
- **Doubles in Jail** do NOT grant an additional turn after exit.
- **Go To Jail via 3rd doubles**: the player does NOT move on the 3rd doubles roll; they jump straight to Jail.
- **Landing on GO** pays $200 (same as passing); no "double salary" officially.
- **GOOJF cards are tradable** and transferred on player-to-player bankruptcy.
- **Mortgaged properties pay no rent**, but still count for RR/utility tier ownership per modern rules (**[AMBIGUITY]** across older editions).
- **Building/mortgaging is allowed during other players' turns** per the literal rulebook text, though most digital implementations restrict to owner's turn.

---

## Common Implementation Pitfalls

The 10 most frequently broken rules in home-brewed Monopoly implementations. Audit your Flutter code for each of these:

1. **Auction skipped on decline.** Many implementations let a player decline a property and pass the turn. Per official rules, the Bank MUST auction to all players (including the decliner) with any bid >= $1 accepted.
2. **Utility rent wrong.** Common bug: using a flat rent value (e.g., 4 or 10) or using the rent card values. Correct formula: **4 x dice roll** (1 utility owned) or **10 x dice roll** (both owned). The dice roll is the roll that landed the opponent on the utility. Exception: Chance "Advance to nearest Utility" forces **10x** regardless of how many utilities the owner holds, and the player rolls fresh dice.
3. **Monopoly rent x2 applied regardless of house count.** The x2 unimproved rent only applies when owner has the full color group AND no houses are built on any property in that group. If even 1 house exists on one property, all other bare properties in the group still charge only base rent (NOT x2) — **[AMBIGUITY]**: actually, most rule editions DO apply x2 bare-monopoly rent on unimproved properties even if siblings have houses. Re-check your edition. Official current rule: x2 applies on bare properties only when the ENTIRE group is unbuilt.
4. **Even-build rule not enforced.** Players must be prevented from stacking houses on one property while others in the group have fewer (max difference = 1). Same applies for selling back — enforce even-sell.
5. **Jail-doubles counter not reset correctly.** The "3 consecutive doubles to jail" counter must be per-turn, reset on: end of turn, landing on Go To Jail, being sent to jail by any means. It should NOT be shared with the "3 attempts to roll doubles to leave jail" counter, which is per-jail-sentence.
6. **Mortgage transfer fee missed.** When a mortgaged property is traded, the new owner must pay either 10% (keep mortgaged) or mortgage+10% (unmortgage now). Many implementations silently transfer with no fee.
7. **Bankruptcy to Bank not auctioning.** When a player goes bankrupt to the Bank, their properties are auctioned one by one — many implementations just return them to "unowned / bank-held" with no auction.
8. **3-doubles sends player but still moves them.** On the 3rd consecutive double, the player must NOT move. Many implementations move the token by the 3rd roll's dice sum and also send to jail — wrong. Jail only, no movement.
9. **GOOJF (Get Out of Jail Free) card bugs.** Common bugs: card can't be traded, card not added to owner's inventory, both decks' cards pooled incorrectly, or card not returned to the correct deck when used. Official: tradable, tracked per-deck-of-origin, and returned to the bottom of its originating deck when used.
10. **House/hotel shortage not enforced.** The Bank has a hard limit of 32 houses and 12 hotels. Most implementations treat supply as infinite. Enforcing this (with the shortage auction) meaningfully changes strategy — tournaments rely on it.

Honorable mentions:
- **Rent collected on mortgaged properties.** A mortgaged property must yield $0 rent; many implementations still compute rent.
- **Rent collected while owner is in Jail.** Owners in Jail DO still collect rent; do not disable this.
- **Passing GO vs landing on GO.** Both pay $200, not one or the other. "Go back 3 spaces" from Chance does NOT trigger a "pass GO" even if the backward move crosses GO — because you don't technically pass GO going backward.
- **Advance cards and passing GO.** "Advance to ..." cards pay $200 if passing GO; but "Go to Jail" does NOT pay even if the token would cross GO.
- **Income Tax amount varies by edition.** Flat $200 in modern editions; older editions offered 10% of assets or $200 player's choice. Confirm your edition.
- **Luxury Tax amount varies.** $100 modern, $75 older.
