---
name: seat-bus-images
description: >-
  redBus India seat-utility image and New Bus image analytics: CTR for
  SEAT_UTILITY_IMAGES_ON_CLICK_AB, NewBusImageLoaded coverage, and route-level
  transaction share versus India by platform. Use when the user asks about seat
  images, SeatImgSectionClicked, NewImagesClicked, NewBusImageLoaded, bus image
  CTR, or route txn share.
---

# Seat images and bus images

Android and iOS IND on `user_interaction.ui_ux_events` unless the file says tickets. Run [`references/`](references/) on Data Platform / Iceberg. Change only the UTC window. IST day start = previous day `18:30` UTC.

Confirmed tickets, when the file uses them: `transaction.bus_ticket_events`, `country_code = 'IND'`, `event_type = 101`, `event_class = 2`.

## CTR

Experiment on `search_details.channel_exp_info`: `SEAT_UTILITY_IMAGES_ON_CLICK_AB:V0` / `V1` / `V2`.

```
CTR = sessions with SeatImgSectionClicked OR NewImagesClicked
      ÷ sessions with NewBusImageLoaded
```

| Ask | File |
|---|---|
| CTR by variant, no route list | [seat_image_ctr_s1.sql](references/seat_image_ctr_s1.sql) |
| CTR with the route list | [seat_image_ctr_s2.sql](references/seat_image_ctr_s2.sql) |
| iOS route-list CTR | [seat_image_ctr_s2_ios.sql](references/seat_image_ctr_s2_ios.sql) |
| By platform | [seat_image_ctr_s2_by_platform.sql](references/seat_image_ctr_s2_by_platform.sql) |
| Overall route-list CTR | [seat_image_ctr_s2_overall.sql](references/seat_image_ctr_s2_overall.sql) |
| Click / load / details-expanded coverage by app version | [new_images_coverage_query.sql](references/new_images_coverage_query.sql) |

`new_images_coverage_query.sql` filters `event_group = 'sl_click_info'` and Android app versions in the file (`82.2.0`, `82.2.51`, `82.3.0`). Keep that version list unless the user names others.

## Transaction share

| Ask | File |
|---|---|
| India txn and seat share by sales channel | [india_txn_share_by_platform_last7d.sql](references/india_txn_share_by_platform_last7d.sql) |
| Android routes that loaded NewBusImageLoaded, their txn share | [_newbusimage_android_txn_share_aug19_24.sql](references/_newbusimage_android_txn_share_aug19_24.sql) |
| Route txn share by platform | [route_txn_share_by_platform.sql](references/route_txn_share_by_platform.sql) |
| Same share, 6–17 Aug window | [route_txn_share_aug6_17.sql](references/route_txn_share_aug6_17.sql) |
| Route vs overall India, last 3 days | [route_vs_overall_txn_share_by_platform_last3d.sql](references/route_vs_overall_txn_share_by_platform_last3d.sql) |
| Route vs overall India, last 7 days | [route_vs_overall_txn_share_by_platform_last7d.sql](references/route_vs_overall_txn_share_by_platform_last7d.sql) |

Platform labels on tickets: `RB:MOBILEWEB#droidapp` = Android, `RB:MOBILEWEB#iosapp` = iOS, `WEBDIRECT` = Desktop, `MOBILEWEB` = MobWeb.

Route-list files already contain the route ids. Do not rebuild the list.
