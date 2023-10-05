CREATE SCHEMA before;

DROP TABLE IF EXISTS before.agency CASCADE;
CREATE TABLE before.agency
(
  agency_id              text UNIQUE NULL,
  agency_name            text NOT NULL,
  agency_url             text NOT NULL,
  agency_timezone        text NOT NULL,
  agency_lang            text NULL,
  agency_phone           text NULL
);

DROP TABLE IF EXISTS before.stops CASCADE;
CREATE TABLE before.stops
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

DROP TABLE IF EXISTS before.routes CASCADE;
CREATE TABLE before.routes
(
  route_id               text PRIMARY KEY,
  agency_id              text NULL REFERENCES before.agency(agency_id) ON DELETE CASCADE ON UPDATE CASCADE,
  route_short_name       text NULL,
  route_long_name        text NULL CHECK (route_short_name IS NOT NULL OR route_long_name IS NOT NULL),
  route_desc             text NULL,
  route_type             integer NOT NULL,
  route_url              text NULL
);

DROP TABLE IF EXISTS before.trips CASCADE;
CREATE TABLE before.trips
(
  route_id               text NOT NULL REFERENCES before.routes ON DELETE CASCADE ON UPDATE CASCADE,
  service_id             text NOT NULL,
  trip_id                text NOT NULL PRIMARY KEY,
  trip_short_name        text NULL,
  direction_id           boolean NULL,
  block_id               text NULL,
  shape_id               text NULL
);

DROP TABLE IF EXISTS before.stop_times CASCADE;
CREATE TABLE before.stop_times
(
  trip_id                text NOT NULL REFERENCES before.trips ON DELETE CASCADE ON UPDATE CASCADE,
  arrival_time           interval NULL,
  departure_time         interval NOT NULL,
  stop_id                text NOT NULL REFERENCES before.stops ON DELETE CASCADE ON UPDATE CASCADE,
  stop_sequence          integer NOT NULL CHECK (stop_sequence >= 0),
  pickup_type            integer NOT NULL CHECK (pickup_type >= 0 AND pickup_type <= 3),
  drop_off_type          integer NOT NULL CHECK (drop_off_type >= 0 AND drop_off_type <= 3)
);

DROP TABLE IF EXISTS before.calendar CASCADE;
CREATE TABLE before.calendar
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

DROP TABLE IF EXISTS before.calendar_dates CASCADE;
CREATE TABLE before.calendar_dates
(
  service_id             text NOT NULL,
  date                   numeric(8) NOT NULL,
  exception_type         integer NOT NULL CHECK (exception_type >= 1 AND exception_type <= 2)
);

DROP TABLE IF EXISTS before.shapes CASCADE;
CREATE TABLE before.shapes
(
  shape_id               text NOT NULL,
  shape_pt_lat           double precision NOT NULL,
  shape_pt_lon           double precision NOT NULL,
  shape_pt_sequence      integer NOT NULL CHECK (shape_pt_sequence >= 0)
);

DROP TABLE IF EXISTS before.feed_info CASCADE;
CREATE TABLE before.feed_info
(
  feed_publisher_name    text NOT NULL,
  feed_publisher_url     text NOT NULL,
  feed_lang              text NULL,
  default_lang           text NULL,
  feed_start_date        numeric(8) NULL,
  feed_contact_email     text NULL,
  feed_contact_url       text NULL
);

\COPY before.agency FROM '../GTFS20221201/agency.txt' (FORMAT CSV, HEADER)
\COPY before.stops FROM '../GTFS20221201/stops.txt' (FORMAT CSV, HEADER)
\COPY before.routes FROM '../GTFS20221201/routes.txt' (FORMAT CSV, HEADER)
\COPY before.trips FROM '../GTFS20221201/trips.txt' (FORMAT CSV, HEADER)
\COPY before.stop_times FROM '../GTFS20221201/stop_times.txt' (FORMAT CSV, HEADER)
\COPY before.calendar FROM '../GTFS20221201/calendar.txt' (FORMAT CSV, HEADER)
\COPY before.calendar_dates FROM '../GTFS20221201/calendar_dates.txt' (FORMAT CSV, HEADER)
\COPY before.shapes FROM '../GTFS20221201/shapes.txt' (FORMAT CSV, HEADER)
\COPY before.feed_info FROM '../GTFS20221201/feed_info.txt' (FORMAT CSV, HEADER)
