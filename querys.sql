-- advance sql project -- spotify dataset
drop table if exists spotify;
create table spotify (
artist varchar(255),
track varchar(255),
album varchar (255),
album_type varchar(50),
danceability float,
enery float,
loudness float,
speechiness float,
acousticness float,
instrumentalness float,
liveness float,
valence float,
tempo float,
duration_min float,
title varchar(255),
channel varchar(255),
view float,
likes bigint,
comments bigint,
licensed boolean,
official_video boolean,
stream bigint,
energy_liveness float,
most_played_on varchar(50)
);
---------------------------------------
-- basic querys
---------------------------------------
-- Retrieve the names of all tracks that have more than 1 billion streams.
select track from spotify 
where 
stream > 1000000000;

--List all albums along with their respective artists.
select album,artist from spotify ;

--Get the total number of comments for tracks where licensed = TRUE.
select sum(comments) from spotify where licensed = TRUE;

--Find all tracks that belong to the album type single.
select track , album_type from spotify where album_type = 'single';

--Count the total number of tracks by each artist.
select artist,count(track) from spotify group by artist;
--------------------------------------------------
--medium level queries
--------------------------------------------------
--Calculate the average danceability of tracks in each album.
select album,avg(danceability) as avg_danceability from spotify group by 1;

--Find the top 5 tracks with the highest energy values.
select track,max(enery) from spotify  group by 1 order by 2 desc limit 5;

--List all tracks along with their views and likes where official_video = TRUE.
select track , view ,likes from spotify where official_video = TRUE;

--For each album, calculate the total views of all associated tracks.
select album, sum(view) as total_views from spotify group by album ;

--Retrieve the track names that have been streamed on Spotify more than YouTube
select track from spotify group by track having 
sum(case when most_played_on = 'Spotify'then stream else 0 end)>
sum(case when most_played_on = 'YouTube'then stream else 0 end)

--------------------------------------------------
--Advance level queries
--------------------------------------------------
--Find the top 3 most-viewed tracks for each artist using window functions.
select 
artist,track ,view from 
(select 
artist,
view,
track,
Row_Number() over( partition by artist order by view desc)as rn from spotify)ranking_track 
where rn <= 3;

--Write a query to find tracks where the liveness score is above the average.
select track , liveness from spotify where liveness >(select avg(liveness) from spotify);

--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with album_energy as(
select album , max(enery)as max_energy,min(enery)as min_energy from spotify group by album ) 
select album , max_energy-min_energy as energy_diff from album_energy order by 2 desc;

--Find tracks where the energy-to-liveness ratio is greater than 1.2.
select track , album , enery/liveness as energy_liveness 
from spotify 
where liveness > 0 and enery / liveness > 1.2;

--Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select track , view , sum(likes) 
over (order by view rows between unbounded preceding and current row 
) as cumulative_likes
from spotify ;