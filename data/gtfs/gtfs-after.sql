CREATE SCHEMA after;

DROP TABLE IF EXISTS after.agency CASCADE;
CREATE TABLE after.agency
(
  agency_id              text UNIQUE NULL,
  agency_name            text NOT NULL,
  agency_url             text NOT NULL,
  agency_timezone        text NOT NULL,
  agency_lang            text NULL,
  agency_phone           text NULL
);

DROP TABLE IF EXISTS after.stops CASCADE;
CREATE TABLE after.stops
(
  stop_id                text PRIMARY KEY,
  stop_code              text NULL,
  stop_name              text NULL CHECK (location_type >= 0 AND location_type <= 2 AND stop_name IS NOT NULL OR location_type > 2),
  stop_desc              text NULL,
  stop_lat               double precision NULL CHECK (location_type >= 0 AND location_type <= 2 AND stop_name IS NOT NULL OR location_type > 2),
  stop_lon               double precision NULL CHECK (location_type >= 0 AND location_type <= 2 AND stop_name IS NOT NULL OR location_type > 2),
  zone_id                text NULL,
  stop_url               text NULL,
  location_type          integer NULL CHECK (location_type >= 0 AND location_type <= 4)
);

DROP TABLE IF EXISTS after.routes CASCADE;
CREATE TABLE after.routes
(
  route_id               text PRIMARY KEY,
  agency_id              text NULL REFERENCES after.agency(agency_id) ON DELETE CASCADE ON UPDATE CASCADE,
  route_short_name       text NULL,
  route_long_name        text NULL CHECK (route_short_name IS NOT NULL OR route_long_name IS NOT NULL),
  route_desc             text NULL,
  route_type             integer NOT NULL,
  route_url              text NULL
);

DROP TABLE IF EXISTS after.trips CASCADE;
CREATE TABLE after.trips
(
  route_id               text NOT NULL REFERENCES after.routes ON DELETE CASCADE ON UPDATE CASCADE,
  service_id             text NOT NULL,
  trip_id                text NOT NULL PRIMARY KEY,
  trip_short_name        text NULL,
  direction_id           boolean NULL,
  block_id               text NULL,
  shape_id               text NULL
);

DROP TABLE IF EXISTS after.stop_times CASCADE;
CREATE TABLE after.stop_times
(
  trip_id                text NOT NULL REFERENCES after.trips ON DELETE CASCADE ON UPDATE CASCADE,
  arrival_time           interval NULL,
  departure_time         interval NOT NULL,
  stop_id                text NOT NULL REFERENCES after.stops ON DELETE CASCADE ON UPDATE CASCADE,
  stop_sequence          integer NOT NULL CHECK (stop_sequence >= 0),
  pickup_type            integer NOT NULL CHECK (pickup_type >= 0 AND pickup_type <= 3),
  drop_off_type          integer NOT NULL CHECK (drop_off_type >= 0 AND drop_off_type <= 3)
);

DROP TABLE IF EXISTS after.calendar CASCADE;
CREATE TABLE after.calendar
(
  service_id             text PRIMARY KEY,
  monday                 boolean NOT NULL,
  tuesday                boolean NOT NULL,
  wednesday              boolean NOT NULL,
  thursday               boolean NOT NULL,
  friday                 boolean NOT NULL,
  saturday               boolean NOT NULL,
  sunday                 boolean NOT NULL,
  start_date             numeric(8) NOT NULL,
  end_date               numeric(8) NOT NULL
);

DROP TABLE IF EXISTS after.calendar_dates CASCADE;
CREATE TABLE after.calendar_dates
(
  service_id             text NOT NULL,
  date                   numeric(8) NOT NULL,
  exception_type         integer NOT NULL CHECK (exception_type >= 1 AND exception_type <= 2)
);

DROP TABLE IF EXISTS after.shapes CASCADE;
CREATE TABLE after.shapes
(
  shape_id               text NOT NULL,
  shape_pt_lat           double precision NOT NULL,
  shape_pt_lon           double precision NOT NULL,
  shape_pt_sequence      integer NOT NULL CHECK (shape_pt_sequence >= 0)
);

DROP TABLE IF EXISTS after.feed_info CASCADE;
CREATE TABLE after.feed_info
(
  feed_publisher_name    text NOT NULL,
  feed_publisher_url     text NOT NULL,
  feed_lang              text NULL,
  default_lang           text NULL,
  feed_start_date        numeric(8) NULL,
  feed_contact_email     text NULL,
  feed_contact_url       text NULL
);

\COPY after.agency FROM '../GTFS20230925/agency.txt' (FORMAT CSV, HEADER)
\COPY after.stops FROM '../GTFS20230925/stops.txt' (FORMAT CSV, HEADER)
\COPY after.routes FROM '../GTFS20230925/routes.txt' (FORMAT CSV, HEADER)
\COPY after.trips FROM '../GTFS20230925/trips.txt' (FORMAT CSV, HEADER)
\COPY after.stop_times FROM '../GTFS20230925/stop_times.txt' (FORMAT CSV, HEADER)
\COPY after.calendar FROM '../GTFS20230925/calendar.txt' (FORMAT CSV, HEADER)
\COPY after.calendar_dates FROM '../GTFS20230925/calendar_dates.txt' (FORMAT CSV, HEADER)
\COPY after.shapes FROM '../GTFS20230925/shapes.txt' (FORMAT CSV, HEADER)
\COPY after.feed_info FROM '../GTFS20230925/feed_info.txt' (FORMAT CSV, HEADER)
