DROP VIEW IF EXISTS flatten;
DROP FOREIGN TABLE IF EXISTS stop_times;
DROP FOREIGN TABLE IF EXISTS stops;
DROP FOREIGN TABLE IF EXISTS trips;
DROP FOREIGN TABLE IF EXISTS routes;
DROP FOREIGN TABLE IF EXISTS calendar;

CREATE FOREIGN TABLE stop_times (
  trip_id VARCHAR(255),
  arrival_time VARCHAR(40),
  departure_time VARCHAR(40),
  stop_id VARCHAR(40),
  stop_sequence VARCHAR(40),
  pickup_type VARCHAR(40),
  drop_off_type VARCHAR(40)
) SERVER gtfs
OPTIONS ( filename '/tmp/gtfs/stop_times.txt', format 'csv' );

CREATE FOREIGN TABLE stops (
  stop_id VARCHAR(40),
  stop_code VARCHAR(40),
  stop_name VARCHAR(255),
  stop_desc VARCHAR(40),
  stop_lat VARCHAR(40),
  stop_lon VARCHAR(40),
  zone_id VARCHAR(40),
  stop_url VARCHAR(40),
  location_type VARCHAR(40)
) SERVER gtfs
OPTIONS ( filename '/tmp/gtfs/stops.txt', format 'csv' );

CREATE FOREIGN TABLE trips (
  route_id VARCHAR(40),
  service_id VARCHAR(40),
  trip_id VARCHAR(255),
  trip_short_name VARCHAR(40),
  direction_id VARCHAR(40),
  block_id VARCHAR(40),
  shape_id VARCHAR(40)
) SERVER gtfs
OPTIONS ( filename '/tmp/gtfs/trips.txt', format 'csv' );

CREATE FOREIGN TABLE routes (
  route_id VARCHAR(40),
  agency_id VARCHAR(40),
  route_short_name VARCHAR(40),
  route_long_name VARCHAR(255),
  route_desc VARCHAR(40),
  route_type VARCHAR(40),
  route_url VARCHAR(40)
) SERVER gtfs
OPTIONS ( filename '/tmp/gtfs/routes.txt', format 'csv' );

CREATE FOREIGN TABLE calendar (
  service_id VARCHAR(40),
  monday VARCHAR(40),
  tuesday VARCHAR(40),
  wednesday VARCHAR(40),
  thursday VARCHAR(40),
  friday VARCHAR(40),
  saturday VARCHAR(40),
  sunday VARCHAR(40),
  start_date VARCHAR(40),
  end_date VARCHAR(40)
) SERVER gtfs
OPTIONS ( filename '/tmp/gtfs/calendar.txt', format 'csv' );

DROP VIEW IF EXISTS flatten;
CREATE VIEW flatten AS
SELECT
  r.route_short_name AS b_name,
  r.route_long_name AS bl_title,
  t.service_id AS bl_variant,
  t.trip_short_name AS bl_num,
  t.direction_id AS bl_direction,
  s.stop_name AS bs_name,
  st.arrival_time AS bs_time,
  monday || tuesday || wednesday || thursday || friday || saturday || sunday AS bl_days,
  c.start_date AS bl_since,
  c.end_date AS bl_until,
  st.stop_sequence AS bs_seqnum,
  s.stop_lat AS bs_latitude,
  s.stop_lon AS bs_longitude
FROM
  routes r
JOIN
  trips t ON t.route_id = r.route_id
JOIN
  stop_times st ON st.trip_id = t.trip_id
JOIN
  stops s ON st.stop_id = s.stop_id
JOIN
  calendar c ON c.service_id = t.service_id
WHERE
  r.agency_id = 'N'
AND
  r.route_short_name IN ('147a','247a','347a','144a')
--  r.route_short_name IN ('831','832','833','E83','E85','E5')
;

COPY
  (SELECT * FROM flatten)
TO
  '/tmp/gtfs/GTFS20230915.newlines.csv'
WITH
  CSV
  DELIMITER ','
  HEADER
  QUOTE '"'
;


SELECT
  r.route_short_name,
  r.route_long_name
FROM
  before.routes r
WHERE
  r.agency_id = 'N'
AND
  r.route_long_name ~* 'Sombreffe|Ligny|Tamines|Sambreville|Fleurus|Jemeppe-sur-Sambre|Spy|Mazy|Farciennes|Châtelet|Corroy-Château|Tongrinne|Onoz'
;

SELECT
  r.route_short_name,
  r.route_long_name
FROM
  routes r
WHERE
  r.route_long_name ~* 'Balâtre'
;

select
  b_name,
  bl_num,
  bs_name,
  bs_seqnum::int,
  bs_latitude,
  bs_longitude
from
  before.lego_tec_flatten
where
  (b_name = '144a')
and
  bl_variant='N_2023-SC-EXA-Sem-N-3-06'
and
  bl_direction='0'
and
  bl_num = 6
ORDER BY
  b_name,
  bl_num,
  bs_seqnum::int
;
