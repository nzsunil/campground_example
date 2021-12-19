USE [DatabaseName]
GO
IF OBJECT_ID(N'dbo.Visitor', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.Visitors
	(
		VisitorId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
		FirstName VARCHAR(100) NOT NULL,
		LastName VARCHAR(100) NOT NULL,
		Email VARCHAR(200) NOT NULL,
		PhoneNumber VARCHAR(50) NOT NULL,
		DateAdded DATETIME NULL,
		DateUpdated DATETIME NULL
	)
	CREATE UNIQUE INDEX IX_Visitors_Email ON dbo.Visitors (Email);
END
GO
IF OBJECT_ID(N'dbo.Campsites', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.Campsites
	(
		CampsiteId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
		SiteName VARCHAR(200) NOT NULL,
		Address1 VARCHAR(100)  NOT NULL,
		Address2 VARCHAR(100)  NOT NULL,
		City VARCHAR(100) NOT NULL,
		State CHAR(2) NOT NULL,
		ZipCode VARCHAR(100) NOT NULL,
		TotalSlotsAvailable SMALLINT NOT NULL,
		Latitude  Decimal(8,6) NULL,
		Longitude Decimal(9,6)  NULL,
		DateAdded DATETIME NULL,
		DateUpdated DATETIME NULL
	)
	CREATE UNIQUE INDEX IX_Campsite_Name ON dbo.Campsites (SiteName);
END
GO
IF OBJECT_ID(N'dbo.Reservations', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.Reservations
	(
		ReservationId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
		VisitorId INT NOT NULL,
		CampsiteId INT NOT NULL,
	--	SlotNumber SMALLINT NOT NULL,
		ReservationDate DATE NOT NULL,
		ConfirmationCode CHAR(6) NOT NULL,
		IsCancelled BIT NOT NULL,
		DateAdded DATETIME NULL,
		DateUpdated DATETIME NULL
	)
	CREATE UNIQUE INDEX IX_Reservations_CId_VId_RDate ON dbo.Reservations (CampsiteId, VisitorId, ReservationDate);
	CREATE INDEX IX_Reservations_RDate_CId ON dbo.Reservations (ReservationDate, CampsiteId) INCLUDE (IsCancelled);
END
GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	Create Day Calendar
-- EXEC dbo.CreateCalendarTable;
-- =============================================
CREATE OR ALTER PROC dbo.CreateCalendarTable
AS
BEGIN
	SET NOCOUNT ON;
	IF OBJECT_ID (N'Calendar', N'U') IS NOT NULL 
		DROP TABLE dbo.Calendar;

	DECLARE @Year INT = YEAR(GETDATE());
	DECLARE @YearCnt INT = 2;
	DECLARE @StartDate DATE = DATEFROMPARTS(@Year, '01', '01');

	DECLARE @EndDate DATE = DATEADD(DAY, -1, DATEADD(YEAR, @YearCnt, @StartDate));

	;WITH Cal (n)
	AS (SELECT 0
		UNION ALL
		SELECT n + 1
		FROM Cal
		WHERE n < DATEDIFF(DAY, @StartDate, @EndDate)),
		  FnlDt (d)
	AS (SELECT DATEADD(DAY, n, @StartDate)
		FROM Cal),
		  FinalCte
	AS (SELECT [Date] = CONVERT(DATE, d),
			   [Day] = DATEPART(DAY, d),
			   [Month] = DATENAME(MONTH, d),
			   [Year] = DATEPART(YEAR, d),
			   [DayName] = DATENAME(WEEKDAY, d)
		FROM FnlDt)
	SELECT *
	INTO dbo.Calendar
	FROM FinalCte
	ORDER BY [Date]
	OPTION (MAXRECURSION 0);
	
	CREATE UNIQUE CLUSTERED INDEX CIX_Calendar_date ON dbo.Calendar(Date);
END
GO
EXEC dbo.CreateCalendarTable;
GO
IF OBJECT_ID('dbo.FK_Reservations_Calendar') IS NULL
BEGIN
	ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservations_Calendar] FOREIGN KEY([ReservationDate]) REFERENCES [dbo].[Calendar] ([Date])
	ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Reservations_Calendar]
END
GO
IF OBJECT_ID('dbo.FK_Reservations_Campsite') IS NULL
BEGIN
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservations_Campsite] FOREIGN KEY([CampsiteId]) REFERENCES dbo.Campsites ([CampsiteId])
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Reservations_Campsite]
END
GO
IF OBJECT_ID('dbo.FK_Reservations_Visitors') IS NULL
BEGIN
	ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservations_Visitors] FOREIGN KEY([VisitorId]) REFERENCES [dbo].[Visitors] ([VisitorId])
	ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Reservations_Visitors]
END
GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	Creare dummy data for campsite
-- EXEC dbo.InsertDummyCampsiteData;
-- =============================================
CREATE OR ALTER PROC dbo.InsertDummyCampsiteData
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Counter INT = 1,
			@CurrentDate DATETIME = GETDATE();
	WHILE ( @Counter <= 6)
	BEGIN	
		INSERT INTO dbo.Campsites
		(
			SiteName,
			Address1,
			Address2,
			City,
			State,
			ZipCode,
			TotalSlotsAvailable,
			Latitude,
			Longitude,
			DateAdded,
			DateUpdated
		)
		VALUES
		(   'CampsiteName' + CAST(@Counter AS VARCHAR(10)),   -- SiteName - varchar(200)
			'Address' + CAST(@Counter AS VARCHAR(10)),   -- Address1 - varchar(100)
			'',   -- Address2 - varchar(100)
			'MyCity' + CAST(@Counter AS VARCHAR(10)),   -- City - varchar(100)
			'UT',   -- State - char(2)
			'8409' + CAST(@Counter AS VARCHAR(10)),   -- ZipCode - varchar(100)
			FLOOR(RAND()*(25)+1),    -- TotalSlotsAvailable - smallint
			NULL, -- Latitude - decimal(8, 6)
			NULL, -- Longitude - decimal(9, 6)
			@CurrentDate, -- DateAdded - datetime
			@CurrentDate  -- DateUpdated - datetime
			)

		SET @Counter+= 1
	END
END
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	CREATE DUMMY DATA FOR dbo.Visitors
-- EXEC dbo.InsertDummyVisitorsData;
-- =============================================
CREATE OR ALTER PROC dbo.InsertDummyVisitorsData
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Counter INT = 1,
			@CurrentDate DATETIME = GETDATE();
	WHILE ( @Counter <= 100)
	BEGIN	
		INSERT INTO dbo.Visitors
		(
			FirstName,
			LastName,
			Email,
			PhoneNumber,
			DateAdded,
			DateUpdated
		)
		VALUES
		(   'VisitorFirstName' + CAST(@Counter AS VARCHAR(10)),   -- FirstName - varchar(100)
			'VisitorLastName'+ CAST(@Counter AS VARCHAR(10)),   -- LastName - varchar(100)
			'visitor' + CAST(@Counter AS VARCHAR(10)) + '@myemail.com',   -- Email - varchar(200)
			'8019' + CAST(FLOOR(RAND()*(250000)+100000) AS VARCHAR(12)),   -- PhoneNumber - varchar(50)
			@CurrentDate, -- DateAdded - datetime
			@CurrentDate  -- DateUpdated - datetime
			)	

		SET @Counter+= 1
	END
END
GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	CREATE DUMMY DATA FOR dbo.Reservations
-- EXEC  dbo.Generate_Reservations;
-- =============================================
CREATE OR ALTER PROC dbo.Generate_Reservations
AS
	/* -- Add reservations
		EXEC dbo.Generate_Reservations
		GO 100;
	*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @Counter INT = 1,
			@CurrentDate DATETIME = GETDATE(),
			@TotalSlotsAvailable SMALLINT;
	WHILE ( @Counter <= 6)
	BEGIN	
		DECLARE @TotalVisitorsToAdd INT,
				@Counter2 SMALLINT = 1,
				@ResrvationDate DATE;
		SELECT @TotalSlotsAvailable = TotalSlotsAvailable FROM dbo.Campsites WHERE CampsiteId = @Counter;
		SELECT @TotalVisitorsToAdd = FLOOR(RAND()*(@TotalSlotsAvailable)+1)
		WHILE @Counter2 <= @TotalVisitorsToAdd
		BEGIN
			BEGIN TRY
				SELECT @ResrvationDate = DATEADD(d, ROUND(DateDiff(d, '2021-12-18', '2022-02-18') * RAND(CHECKSUM(NEWID())), 0), DATEADD(SECOND,CHECKSUM(NEWID())%48000, '2021-12-18'));
				IF ((SELECT COUNT(*) FROM dbo.Reservations WHERE CampsiteId = @Counter AND ReservationDate = @ResrvationDate AND IsCancelled = 0) < @TotalSlotsAvailable)
				INSERT INTO dbo.Reservations
				(
					VisitorId,
					CampsiteId,
					ReservationDate,
					ConfirmationCode,
					IsCancelled,
					DateAdded,
					DateUpdated
				)
				VALUES
				(   FLOOR(RAND()*(100)+1),         -- VisitorId - int
					@Counter,         -- CampsiteId - int
					@ResrvationDate, -- ReservationDate - date
					LEFT(NEWID(),6),        -- ConfirmationCode - char(6)
					CONVERT(bit,SUBSTRING(CONVERT(binary(18),newid()),1,1)&1),      -- IsCancelled - bit
					GETDATE(),      -- DateAdded - datetime
					GETDATE()       -- DateUpdated - datetime
					)
				SET @Counter2+= 1;
			
			END TRY
			BEGIN CATCH
			END CATCH
		END
		SET @Counter+= 1;
	END;
END
GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	Book or cancel reservations
-- =============================================
CREATE OR ALTER PROC dbo.Manage_reservation
	@VisitorID INT,
	@CampsiteID INT,
	@ReservationDate DATE,
	@IsCancelReservation BIT,
	@RebookCancelledReservation BIT,
	@ReturnConfirmationCode CHAR(6) OUTPUT,
	@ReturnMessage VARCHAR(4000) OUTPUT
AS
/*
	DECLARE @ReturnConfirmationCode CHAR(6),
			@ReturnMessage VARCHAR(4000);
	EXEC Manage_reservation @VisitorID = 13,                                           -- int
							@CampsiteID = 1,                                          -- int
							@ReservationDate = '2022-03-20',                          -- date
							@IsCancelReservation = 0,                              -- bit
							@RebookCancelledReservation = 1,                       -- bit
							@ReturnConfirmationCode = @ReturnConfirmationCode OUTPUT, -- char(6)
							@ReturnMessage = @ReturnMessage OUTPUT                    -- varchar(4000)
	SELECT 
		@ReturnConfirmationCode, @ReturnMessage;

	SELECT * 	FROM dbo.Reservations WHERE CampsiteId = 1 AND VisitorID = 13 AND ReservationDate = '2022-03-20';
*/
BEGIN	
		DECLARE @ReservationId INT = 0,
				@ConfirmationCode CHAR(6),
				@TotalSlotsAvailable SMALLINT,
				@IsCancelled BIT;
		--Retrieve if reservation exists already
		SELECT @ReturnMessage = '';
		SELECT  
			@ReservationId = ReservationId, 
			@ConfirmationCode = ConfirmationCode,
			@IsCancelled = IsCancelled
		FROM 
			dbo.Reservations 
		WHERE 
			CampsiteId = @CampsiteId AND 
			VisitorID = @VisitorID AND
			ReservationDate = @ReservationDate;
		-- Get available slot on campsite
		SELECT 
			@TotalSlotsAvailable = TotalSlotsAvailable 
		FROM 
			dbo.Campsites 
		WHERE 
			CampsiteId = @CampsiteID;

		IF (@ReservationId = 0) -- IF NOT EXISTS THEN CREATE
		BEGIN 
			IF ((SELECT COUNT(*) FROM dbo.Reservations WHERE CampsiteId = @CampsiteId AND ReservationDate = @ReservationDate AND IsCancelled = 1) < @TotalSlotsAvailable)
			BEGIN
				INSERT INTO dbo.Reservations
				(
					VisitorId,
					CampsiteId,
					ReservationDate,
					ConfirmationCode,
					IsCancelled,
					DateAdded,
					DateUpdated
				)
				VALUES
				(   @VisitorID,		-- VisitorId - int
					@CampsiteId,         -- CampsiteId - int
					@ReservationDate,	-- ReservationDate - date
					LEFT(NEWID(),6),        -- ConfirmationCode - char(6)
					0,      -- IsCancelled - bit
					GETDATE(),      -- DateAdded - datetime
					GETDATE()       -- DateUpdated - datetime
				)
				SELECT @ReturnMessage = @ReturnMessage + 'Reservation is created. '

				SELECT @ReservationId = SCOPE_IDENTITY();
				SELECT  
					@ConfirmationCode = ConfirmationCode,
					@IsCancelled = IsCancelled
				FROM 
					dbo.Reservations 
				WHERE 
					ReservationId = @ReservationId;
			END
			ELSE
				SELECT @ReturnMessage = @ReturnMessage + 'No available slots on this date to this site. '
		END
		ELSE IF (@ReservationId > 0)
		BEGIN
			SELECT @ReturnMessage = @ReturnMessage + 'Rreserved found on this date. ' + CASE WHEN @IsCancelled = 1 THEN 'But it is already cancelled. ' ELSE '' END;
			IF (@IsCancelReservation = 1)
			BEGIN
				UPDATE 
					dbo.Reservations
				SET
					IsCancelled = 1,
					DateUpdated = GETDATE()
				WHERE 
					ReservationId = @ReservationId;
				SELECT @ReturnMessage = @ReturnMessage + 'Reservation is now cancelled. '
			END			
			ELSE IF (@RebookCancelledReservation = 1)
			BEGIN
				UPDATE 
					dbo.Reservations
				SET
					IsCancelled = 0,
					DateUpdated = GETDATE(),
					@ReturnMessage = @ReturnMessage + 'Previously cancelled reservation is now booked. '
				WHERE 
					ReservationId = @ReservationId
					AND IsCancelled = 1;
			END
		END

		SELECT @ReturnConfirmationCode = @ConfirmationCode;
END
GO

-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	Check Available Campsite Slots for each day for next six months.
-- =============================================
CREATE OR ALTER VIEW dbo.vw_CheckAvailableCampsiteSlots
AS
	--
	-- SELECT TOP 100 * FROM dbo.vw_CheckAvailableCampsiteSlots ORDER BY ReservationDate
	--
	SELECT C.Date AS ReservationDate,
		   T.CampsiteId,
		   T.SiteName,
		   --T.TotalReserverd, 
		   T.TotalSlotsAvailable
	FROM dbo.Calendar AS C
		 OUTER APPLY
					(
						SELECT CP.CampsiteId,
								CP.SiteName,
								T.TotalReserverd,
								CP.TotalSlotsAvailable - T.TotalReserverd AS TotalSlotsAvailable
						FROM dbo.Campsites AS CP
							 OUTER APPLY
										(
											SELECT ISNULL(COUNT(*), 0) AS TotalReserverd
											FROM dbo.Reservations
											WHERE CampsiteId = CP.CampsiteId
													AND ReservationDate = C.Date
													AND IsCancelled = 0
										) AS T
					) AS T
	WHERE 
		C.Date > CAST(GETDATE() AS DATE)
		AND C.Date <= CAST(GETDATE() + 180 AS DATE)
		AND T.TotalSlotsAvailable > 0; -- BOOK only 6 month in advance.

GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	Get Most Popular day to visit canyon simply based on total number of bookings.
-- SELECT dbo.fn_GetMostPopularDayToVisit();
-- =============================================
CREATE OR ALTER FUNCTION dbo.fn_GetMostPopularDayToVisit 
(
)
RETURNS DATE
AS
BEGIN
	DECLARE @PopularDate DATE = GETDATE()

	SELECT TOP 1
		@PopularDate = R.ReservationDate
	FROM
		dbo.Reservations AS R
	WHERE
		R.IsCancelled = 0
	GROUP BY 
		R.ReservationDate
	ORDER BY 
		COUNT(*) DESC;

	RETURN @PopularDate;
END
GO


----------------------------------------------------------------------------------
-- INSERT DUMMY DATA AND Run some examples
--------------------------------------------------------------------------------
--TRUNCATE TABLE dbo.Reservations;
--TRUNCATE TABLE dbo.Campsites;
--TRUNCATE TABLE dbo.Visitors;
GO
EXEC dbo.InsertDummyVisitorsData;
EXEC dbo.InsertDummyCampsiteData;
GO
EXEC dbo.Generate_Reservations
GO 100

GO
---- Manage reservations -------------------------------------------------------------------
DECLARE @ReturnConfirmationCode CHAR(6),
		@ReturnMessage VARCHAR(4000);
EXEC Manage_reservation @VisitorID = 13,                                           -- int
						@CampsiteID = 1,                                          -- int
						@ReservationDate = '2022-03-20',                          -- date
						@IsCancelReservation = 0,                              -- bit
						@RebookCancelledReservation = 1,                       -- bit
						@ReturnConfirmationCode = @ReturnConfirmationCode OUTPUT, -- char(6)
						@ReturnMessage = @ReturnMessage OUTPUT                    -- varchar(4000)
SELECT 
	@ReturnConfirmationCode, @ReturnMessage;
GO
-------------------------------------------------------------------------------------------
---- Manage reservations -------------------------------------------------------------------
DECLARE @ReturnConfirmationCode CHAR(6),
		@ReturnMessage VARCHAR(4000);
EXEC Manage_reservation @VisitorID = 13,                                           -- int
						@CampsiteID = 1,                                          -- int
						@ReservationDate = '2022-03-20',                          -- date
						@IsCancelReservation = 1,                              -- bit
						@RebookCancelledReservation = 1,                       -- bit
						@ReturnConfirmationCode = @ReturnConfirmationCode OUTPUT, -- char(6)
						@ReturnMessage = @ReturnMessage OUTPUT                    -- varchar(4000)
SELECT 
	@ReturnConfirmationCode, @ReturnMessage;
-------------------------------------------------------------------------------------------
GO
--- CHECK available campsites for perticular date.
SELECT * FROM dbo.vw_CheckAvailableCampsiteSlots WHERE ReservationDate = '2022-02-15';

--- Check popular date for canyon.
SELECT dbo.fn_GetMostPopularDayToVisit() AS MostPopularDate;