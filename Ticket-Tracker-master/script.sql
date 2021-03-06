USE [BusDB]
GO
/****** Object:  Table [dbo].[Buses]    Script Date: 5/02/2020 5:22:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Buses](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[From] [nvarchar](50) NOT NULL,
	[To] [nvarchar](50) NOT NULL,
	[Departure] [datetime] NOT NULL,
	[Arrival] [datetime] NOT NULL,
	[Transfers] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[stop_times]    Script Date: 5/02/2020 5:22:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stop_times](
	[route_id] [int] NOT NULL,
	[stop_sequence] [int] NOT NULL,
	[stop_name] [nvarchar](255) NOT NULL,
	[arrival_time] [time](0) NOT NULL,
	[departure_time] [time](0) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[stops]    Script Date: 5/02/2020 5:22:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stops](
	[stop_id] [nvarchar](3) NOT NULL,
	[stop_name] [nvarchar](255) NOT NULL,
	[stop_desc] [nvarchar](255) NULL,
 CONSTRAINT [PK_Stops] PRIMARY KEY CLUSTERED 
(
	[stop_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[trips]    Script Date: 5/02/2020 5:22:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips](
	[trip_id] [int] NOT NULL,
	[Terminus] [nvarchar](255) NULL,
	[sunday] [bit] NOT NULL,
	[monday] [bit] NOT NULL,
	[tuesday] [bit] NOT NULL,
	[wednesday] [bit] NOT NULL,
	[thursday] [bit] NOT NULL,
	[friday] [bit] NOT NULL,
	[saturday] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[valid_dates]    Script Date: 5/02/2020 5:22:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[valid_dates](
	[route_id] [int] NOT NULL,
	[date] [date] NOT NULL,
	[is_valid] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ValidDates]    Script Date: 5/02/2020 5:22:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValidDates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[From] [nvarchar](50) NOT NULL,
	[To] [nvarchar](50) NOT NULL,
	[Date] [date] NOT NULL,
	[Valid] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[usp_add_valid_date]    Script Date: 5/02/2020 5:22:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_add_valid_date] 
@FromValue nvarchar(50),  @ToValue nvarchar(50), @DateValue Date, @Valid Bit
AS
IF EXISTS (
SELECT * FROM [dbo].[ValidDates]
WHERE [From] = @FromValue
AND [To] = @ToValue
AND [Date] = @DateValue
) SELECT * FROM ValidDates
GO;
GO
/****** Object:  StoredProcedure [dbo].[usp_get_routes]    Script Date: 5/02/2020 5:22:14 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_get_routes]
	-- Add the parameters for the stored procedure here
	@origin nvarchar(50),
	@destination nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



DECLARE @connections table (connection NVARCHAR(50));
INSERT INTO @connections 
VALUES ('Blenheim'), ('Christchurch'), ('Dunedin'), ('Gore'), 
       ('Kerikeri'), ('Palmerston North'), ('Thames'), ('Taupo'), ('New Plymouth');




----------------------- NO CONNECTIONS ---------------------------

SELECT *
  INTO #noconnections0
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name = @origin

SELECT * 
  INTO #noconnections1
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name IN (@destination)
  AND times.route_id IN (SELECT route_id FROM #noconnections0);

SELECT
  #noconnections1.[route_id] AS 'route_id0', #noconnections0.stop_name AS 'stop_name0', #noconnections1.stop_name AS 'stop_name1', #noconnections0.departure_time AS 'departure_time0', #noconnections1.arrival_time AS 'arrival_time1' 
  INTO #noconnections2
  FROM #noconnections1
  INNER JOIN #noconnections0 ON #noconnections0.route_id = #noconnections1.route_id
  WHERE #noconnections0.stop_sequence < #noconnections1.stop_sequence
  ORDER BY route_id0, #noconnections0.stop_sequence

SELECT * FROM #noconnections2
-----------------------  1 CONNECTION  ---------------------------

SELECT *
  INTO #temp0
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name = @origin

SELECT * 
  INTO #temp1
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name IN (SELECT connection FROM @connections)
  AND times.route_id IN (SELECT route_id FROM #temp0);

SELECT
  #temp1.[route_id] AS 'route_id0', #temp0.stop_name AS 'stop_name0', #temp1.stop_name AS 'stop_name1', #temp0.departure_time AS 'departure_time0', #temp1.arrival_time AS 'arrival_time1' 
  INTO #temp2
  FROM #temp1
  INNER JOIN #temp0 ON #temp0.route_id = #temp1.route_id
  WHERE #temp0.stop_sequence < #temp1.stop_sequence
  ORDER BY route_id0, #temp0.stop_sequence

--

SELECT * 
  INTO #tempexample0
  FROM [dbo].[stop_times]
  WHERE [dbo].[stop_times].stop_name IN (SELECT connection FROM @connections)

SELECT * 
  INTO #tempexample1
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name IN (@destination)
  AND times.route_id IN (SELECT route_id FROM #tempexample0)

SELECT
  #tempexample1.[route_id] AS 'route_id0', #tempexample0.[stop_name] AS 'stop_name0', #tempexample1.stop_name AS 'stop_name1', #tempexample0.[departure_time] AS 'departure_time0', #tempexample1.arrival_time AS 'arrival_time1' 
  INTO #tempexample2
  FROM #tempexample1
  INNER JOIN #tempexample0 ON #tempexample0.route_id = #tempexample1.route_id
  WHERE #tempexample0.stop_sequence < #tempexample1.stop_sequence
  AND #tempexample1.route_id NOT IN (SELECT #noconnections2.route_id0 FROM #noconnections2)
  ORDER BY route_id0, #tempexample0.stop_sequence

SELECT 
  [#temp2].[route_id0] as 'first_route_id',
  [#temp2].[stop_name0] as 'first_departure_stop',
  [#temp2].[stop_name1] as 'first_arrival_stop',
  [#temp2].[departure_time0] as 'first_departure_time',
  [#temp2].[arrival_time1] as 'first_arrival_time',
  [#tempexample2].[route_id0] as 'second_route_id',
  [#tempexample2].[stop_name0] as 'second_departure_stop',
  [#tempexample2].[stop_name1] as 'second_arrival_stop',
  [#tempexample2].[departure_time0] as 'second_departure_time',
  [#tempexample2].[arrival_time1] as 'second_arrival_time'
  INTO #oneconnection 
  from #temp2
  INNER JOIN #tempexample2 
  ON #temp2.arrival_time1 < #tempexample2.departure_time0
  AND #temp2.stop_name1 = #tempexample2.stop_name0
  AND cast(dateadd(minute,200,#temp2.arrival_time1) as time) > #tempexample2.departure_time0
  WHERE #temp2.route_id0 NOT IN (SELECT #noconnections2.route_id0 FROM #noconnections2)

SELECT * FROM #oneconnection

-----------------------  2 CONNECTIONS ---------------------------

SELECT *
  INTO #twoconnectionsone0
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name = @origin

SELECT * 
  INTO #twoconnectionsone1
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name IN (SELECT connection FROM @connections)
  AND times.route_id IN (SELECT route_id FROM #twoconnectionsone0);

SELECT
  #twoconnectionsone1.[route_id] AS 'route_id0', #twoconnectionsone0.stop_name AS 'stop_name0', #twoconnectionsone1.stop_name AS 'stop_name1', #twoconnectionsone0.departure_time AS 'departure_time0', #twoconnectionsone1.arrival_time AS 'arrival_time1' 
  INTO #twoconnectionsone2
  FROM #twoconnectionsone1
  INNER JOIN #twoconnectionsone0 ON #twoconnectionsone0.route_id = #twoconnectionsone1.route_id
  WHERE #twoconnectionsone0.stop_sequence < #twoconnectionsone1.stop_sequence
  ORDER BY route_id0, #twoconnectionsone0.stop_sequence

--

SELECT * 
  INTO #twoconnectionstwo0
  FROM [dbo].[stop_times]
  WHERE [dbo].[stop_times].stop_name IN (SELECT connection FROM @connections)

SELECT * 
  INTO #twoconnectionstwo1
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name IN (SELECT connection FROM @connections)
  AND times.route_id IN (SELECT route_id FROM #twoconnectionstwo0)

SELECT
  #twoconnectionstwo1.[route_id] AS 'route_id0'
  , #twoconnectionstwo0.[stop_name] AS 'stop_name0'
  , #twoconnectionstwo1.stop_name AS 'stop_name1'
  , #twoconnectionstwo0.[departure_time] AS 'departure_time0'
  , #twoconnectionstwo1.arrival_time AS 'arrival_time1' 
  INTO #twoconnectionstwo2
  FROM #twoconnectionstwo1
  INNER JOIN #twoconnectionstwo0 ON #twoconnectionstwo0.route_id = #twoconnectionstwo1.route_id
  WHERE #twoconnectionstwo0.stop_sequence < #twoconnectionstwo1.stop_sequence
  AND #twoconnectionstwo1.route_id NOT IN (SELECT #noconnections2.route_id0 FROM #noconnections2)
  ORDER BY route_id0, #twoconnectionstwo0.stop_sequence


SELECT 
  [#twoconnectionsone2].[route_id0] as 'first_route_id',
  [#twoconnectionsone2].[stop_name0] as 'first_departure_stop',
  [#twoconnectionsone2].[stop_name1] as 'first_arrival_stop',
  [#twoconnectionsone2].[departure_time0] as 'first_departure_time',
  [#twoconnectionsone2].[arrival_time1] as 'first_arrival_time',
  [#twoconnectionstwo2 ].[route_id0] as 'second_route_id',
  [#twoconnectionstwo2 ].[stop_name0] as 'second_departure_stop',
  [#twoconnectionstwo2 ].[stop_name1] as 'second_arrival_stop',
  [#twoconnectionstwo2 ].[departure_time0] as 'second_departure_time',
  [#twoconnectionstwo2 ].[arrival_time1] as 'second_arrival_time'
  INTO #twoconnections
  FROM #twoconnectionsone2
  INNER JOIN #twoconnectionstwo2 
  ON #twoconnectionsone2.arrival_time1 < #twoconnectionstwo2.departure_time0
  AND #twoconnectionsone2.stop_name1 = #twoconnectionstwo2.stop_name0
  AND cast(dateadd(minute,200,#twoconnectionsone2.arrival_time1) as time) > #twoconnectionstwo2.departure_time0
  WHERE #twoconnectionsone2.route_id0 NOT IN (SELECT #noconnections2.route_id0 FROM #noconnections2)


--

SELECT * 
  INTO #twoconnectionsthree0
  FROM [dbo].[stop_times]
  WHERE [dbo].[stop_times].stop_name IN (SELECT connection FROM @connections)

SELECT * 
  INTO #twoconnectionsthree1
  FROM [dbo].[stop_times] times 
  WHERE times.stop_name IN (@destination)
  AND times.route_id IN (SELECT route_id FROM #twoconnectionsthree0)

SELECT
  #twoconnectionsthree1.[route_id] AS 'route_id0', #twoconnectionsthree0.[stop_name] AS 'stop_name0', #twoconnectionsthree1.stop_name AS 'stop_name1', #twoconnectionsthree0.[departure_time] AS 'departure_time0', #twoconnectionsthree1.arrival_time AS 'arrival_time1' 
  INTO #twoconnectionsthree2
  FROM #twoconnectionsthree1
  INNER JOIN #twoconnectionsthree0 ON #twoconnectionsthree0.route_id = #twoconnectionsthree1.route_id
  WHERE #twoconnectionsthree0.stop_sequence < #twoconnectionsthree1.stop_sequence
  AND #twoconnectionsthree1.route_id NOT IN (SELECT #noconnections2.route_id0 FROM #noconnections2)
  ORDER BY route_id0, #twoconnectionsthree0.stop_sequence


  SELECT 
  [#twoconnections].[first_route_id],
  [#twoconnections].[first_departure_stop],
  [#twoconnections].[first_arrival_stop],
  [#twoconnections].[first_departure_time],
  [#twoconnections].[first_arrival_time],
  [#twoconnections].[second_route_id],
  [#twoconnections].[second_departure_stop],
  [#twoconnections].[second_arrival_stop] ,
  [#twoconnections].[second_departure_time],
  [#twoconnections].[second_arrival_time],
  [#twoconnectionsthree2].[route_id0] as 'third_route_id',
  [#twoconnectionsthree2].[stop_name0] as 'third_departure_stop',
  [#twoconnectionsthree2].[stop_name1] as 'third_arrival_stop',
  [#twoconnectionsthree2].[departure_time0] as 'third_departure_time',
  [#twoconnectionsthree2].[arrival_time1] as 'third_arrival_time'
  INTO #twoconnectionsFINAL 
  from #twoconnections
  INNER JOIN #twoconnectionsthree2 
  ON #twoconnections.second_arrival_time < #twoconnectionsthree2.departure_time0
  AND #twoconnections.second_arrival_stop = #twoconnectionsthree2.stop_name0
  AND cast(dateadd(minute,200,#twoconnections.second_arrival_time) as time) > #twoconnectionsthree2.departure_time0
  WHERE #twoconnections.second_route_id NOT IN (SELECT #noconnections2.route_id0 FROM #noconnections2)
  AND [#twoconnectionsthree2].[route_id0] NOT IN (SELECT second_route_id FROM #twoconnections)
  
  SELECT * FROM #twoconnectionsFINAL

  --

  	DROP TABLE #noconnections0;DROP TABLE #noconnections1;DROP TABLE #noconnections2;
DROP TABLE #oneconnection; DROP TABLE #twoconnections;
DROP TABLE #temp0;DROP TABLE #temp1;DROP TABLE #temp2;
DROP TABLE #tempexample0;DROP TABLE #tempexample1;DROP TABLE #tempexample2;

DROP TABLE #twoconnectionsone0; DROP TABLE #twoconnectionsone1; DROP TABLE #twoconnectionsone2;
DROP TABLE #twoconnectionstwo0; DROP TABLE #twoconnectionstwo1; DROP TABLE #twoconnectionstwo2;
DROP TABLE #twoconnectionsthree0; DROP TABLE #twoconnectionsthree1; DROP TABLE #twoconnectionsthree2;

DROP TABLE #twoconnectionsFINAL;

END
GO
