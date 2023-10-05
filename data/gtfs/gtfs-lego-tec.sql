DROP VIEW IF EXISTS before.lego_tec_flatten CASCADE;
CREATE VIEW before.lego_tec_flatten AS
SELECT
  'AVANT' as bl_system,
  r.route_short_name AS b_name,
  r.route_long_name AS bl_title,
  substr(t.service_id,8,2) AS bl_variant,
  t.trip_short_name AS bl_num,
  t.direction_id AS bl_direction,
  s.stop_name AS bs_name,
  cast(extract(epoch from cast(st.arrival_time as interval))/60 as integer) AS bs_time,
  cast(cast(monday as int) as text) || cast(cast(tuesday as int) as text) || cast(cast(wednesday as int) as text) || cast(cast(thursday as int) as text) || cast(cast(friday as int) as text) || cast(cast(saturday as int) as text) || cast(cast(sunday as int) as text) AS bl_days,
  c.start_date AS bl_since,
  c.end_date AS bl_until,
  st.stop_sequence AS bs_seqnum,
  s.stop_lat AS bs_latitude,
  s.stop_lon AS bs_longitude
FROM
  before.routes r
JOIN
  before.trips t ON t.route_id = r.route_id
JOIN
  before.stop_times st ON st.trip_id = t.trip_id
JOIN
  before.stops s ON st.stop_id = s.stop_id
JOIN
  before.calendar c ON c.service_id = t.service_id
WHERE
  r.agency_id = 'N'
AND
  r.route_short_name IN ('23','36','58','147a','247a','347a','144a')
;

DROP VIEW IF EXISTS after.lego_tec_flatten CASCADE;
CREATE VIEW after.lego_tec_flatten AS
SELECT
  'APRES' as bl_system,
  r.route_short_name AS b_name,
  r.route_long_name AS bl_title,
  substr(t.service_id,8,2) AS bl_variant,
  t.trip_short_name AS bl_num,
  t.direction_id AS bl_direction,
  s.stop_name AS bs_name,
  cast(extract(epoch from cast(st.arrival_time as interval))/60 as integer) AS bs_time,
  cast(cast(monday as int) as text) || cast(cast(tuesday as int) as text) || cast(cast(wednesday as int) as text) || cast(cast(thursday as int) as text) || cast(cast(friday as int) as text) || cast(cast(saturday as int) as text) || cast(cast(sunday as int) as text) AS bl_days,
  c.start_date AS bl_since,
  c.end_date AS bl_until,
  st.stop_sequence AS bs_seqnum,
  s.stop_lat AS bs_latitude,
  s.stop_lon AS bs_longitude
FROM
  after.routes r
JOIN
  after.trips t ON t.route_id = r.route_id
JOIN
  after.stop_times st ON st.trip_id = t.trip_id
JOIN
  after.stops s ON st.stop_id = s.stop_id
JOIN
  after.calendar c ON c.service_id = t.service_id
WHERE (
  r.agency_id = 'N'
AND
  r.route_short_name IN ('23','58','76','77','831','832','833','851','852','853','854','E83','E85')
) OR (
  r.agency_id = 'B'
AND
  r.route_short_name IN ('E5')
);

DROP VIEW IF EXISTS lego_tec_flatten CASCADE;
CREATE VIEW lego_tec_flatten AS
SELECT
  *
FROM
  before.lego_tec_flatten
UNION ALL
SELECT
  *
FROM
  after.lego_tec_flatten
;
