-- ------------------------
-- Basic Categoties
---------------------------

-- Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream>=100000000;

-- List all albums along with their respective artists.
SELECT DISTINCT album AS album, artist
FROM spotify;

-- Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) AS total_comments
FROM spotify
WHERE licensed = 'true';

-- Find all tracks that belong to the album type single.
SELECT *
FROM spotify
WHERE album_type = 'single';

-- Count the total number of tracks by each artist.
SELECT artist, COUNT(track) AS number_of_tracks
FROM spotify
GROUP BY artist;




-----------------------------------------------------
-- Medium Category
-----------------------------------------------------

-- Calculate the average danceability of tracks in each album.
SELECT
	album,
	AVG(danceability) AS average_danceability
FROM spotify
GROUP BY album;

-- Find the top 5 tracks with the highest energy values.
SELECT 
	track,
	MAX(energy) AS energy
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- List all tracks along with their views and likes where official_video = TRUE.
SELECT
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video='true'
GROUP BY 1;

-- For each album, calculate the total views of all associated tracks.
SELECT
	album,
	track,
	SUM(views) AS total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;

-- Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT *
FROM (
SELECT
	track,
	COALESCE(SUM(CASE WHEN most_played_on='Youtube' THEN stream END),0) AS stream_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on='Spotify' THEN stream END),0) AS stream_on_spotify
FROM spotify
GROUP BY 1
)
WHERE stream_on_youtube < stream_on_spotify AND
stream_on_youtube<>0;



-------------------------------------------------------------------------------------
-- Advance Category
-------------------------------------------------------------------------------------

-- Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist AS(
SELECT
	artist,
	track,
	SUM(views) AS total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC
)

SELECT * FROM ranking_artist
WHERE rank<=3;

-- Write a query to find tracks where the liveness score is above the average.
SELECT *
FROM spotify
WHERE liveness > (
SELECT AVG(liveness) FROM spotify
);


-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH track_energy AS(
SELECT
	album,
	MAX(energy) AS max_energy,
	MIN(energy) AS min_energy
FROM spotify
GROUP BY 1
)

SELECT
album,
(max_energy-min_energy) as difference
FROM track_energy
ORDER BY 2 DESC;


--  Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT 
	track,
	energy / liveness AS energy_to_liveness_ratio
FROM Spotify 
WHERE energy / NULLIF(liveness,0) > 1.2 ;


-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
	track,
	SUM(likes) OVER (ORDER BY views) AS cumulative_sum
FROM Spotify
ORDER BY 2 DESC;