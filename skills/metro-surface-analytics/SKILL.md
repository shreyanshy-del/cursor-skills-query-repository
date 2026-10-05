---
name: metro-surface-analytics
description: >-
  redBus India metro surface analytics after a confirmed metro ticket: Metro
  Home, Metro Card, and Metro Sticky loads on bus buddy, by city and platform.
  Use when the user asks about BusMetro, MetroHomeLanded, MetroCardLoaded,
  MetroStickyLoaded, metro home, metro card, or metro sticky.
---

# Metro home, card, and sticky

India. Run [`references/`](references/) on Data Platform / Iceberg. Change only the UTC window. IST day start = previous day `18:30` UTC.

This is the **bus-buddy surface** after a metro ticket. City DRR and metro-to-bus retention live in the `metro-analytics` skill, not here.

## Confirmed metro buyer

`transaction.addon_item`:

```
country_code = 'IND'
item_type = 13
s_c_t = 'Ticket'
c_t = 'METRO_TICKETING'
event_type = 101
status = 'CONFIRMED'
tin IS NOT NULL
rb_user_id IS NOT NULL AND rb_user_id <> 0
```

Provider → city (do not invent providers):

| service_provider_name | city |
|---|---|
| MaharashtraMetroRailCoLtd | Pune |
| Mumbai Metro One Pvt Ltd | Mumbai |
| Maha Mumbai Metro Operation Corporation Limited | Mumbai |
| Mumbai Metro Rail Corporation Limited | Mumbai |
| Bangalore Metro Rail Corporation Limited | Bangalore |
| Kochi Metro Rail Limited | Ernakulam |
| Chennai Metro Rail Limited | Chennai |
| Delhi Metro Rail Corporation | Delhi |

## Surfaces

`ui_ux_events`, `event_group = 'bus_buddy_click_event'`, `header_country = 'IND'`, `header_bu = 'BUS'`, `selected_country = 'India'`.

| Surface | event_name |
|---|---|
| Home | `BusMetro_MetroHomeLanded` |
| Card | `BusMetro_MetroCardLoaded` |
| Sticky | `BusMetro_MetroStickyLoaded` |
| Meta | `BusMetro_MetroMetaShown` |

| Ask | File |
|---|---|
| Home landed, then later activity | [\_dp_home_after.sql](references/_dp_home_after.sql), [\_dp_home_after_agg.sql](references/_dp_home_after_agg.sql) |
| Home by city | [\_dp_home_after_city.sql](references/_dp_home_after_city.sql), [\_dp_home_after_city_agg.sql](references/_dp_home_after_city_agg.sql) |
| Home user list / source mix / TINs | [\_dp_home_list.sql](references/_dp_home_list.sql), [\_dp_home_src_ov.sql](references/_dp_home_src_ov.sql), [\_dp_home_src_ratio.sql](references/_dp_home_src_ratio.sql), [\_dp_home_tins.sql](references/_dp_home_tins.sql) |
| Sessions after home, overall and city | [\_dp_sess_after_ov.sql](references/_dp_sess_after_ov.sql), [\_dp_sess_after_city.sql](references/_dp_sess_after_city.sql) |
| Card loaded | [\_dp_card_ov.sql](references/_dp_card_ov.sql), [\_dp_card_city.sql](references/_dp_card_city.sql), [\_dp_user_card.sql](references/_dp_user_card.sql) |
| Sticky loaded | [\_dp_user_sticky.sql](references/_dp_user_sticky.sql) |
| Home users | [\_dp_user_home.sql](references/_dp_user_home.sql) |
| All four surfaces together | [\_dp_user_addon.sql](references/_dp_user_addon.sql) |
| Users by city, platform, Android | [\_dp_user_city.sql](references/_dp_user_city.sql), [\_dp_user_plat.sql](references/_dp_user_plat.sql), [\_dp_user_and.sql](references/_dp_user_and.sql), [\_dp_user_overall.sql](references/_dp_user_overall.sql) |
| Metro TIN and user count for the window | [\_dp_metro_week.sql](references/_dp_metro_week.sql) |
