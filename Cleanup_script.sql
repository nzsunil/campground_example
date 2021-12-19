USE [ApexExpress]
GO
/****** Object:  StoredProcedure [dbo].[Manage_reservation]    Script Date: 12/19/2021 12:20:37 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[Manage_reservation]
GO
/****** Object:  StoredProcedure [dbo].[InsertDummyVisitorsData]    Script Date: 12/19/2021 12:20:37 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[InsertDummyVisitorsData]
GO
/****** Object:  StoredProcedure [dbo].[InsertDummyCampsiteData]    Script Date: 12/19/2021 12:20:37 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[InsertDummyCampsiteData]
GO
/****** Object:  StoredProcedure [dbo].[Generate_Reservations]    Script Date: 12/19/2021 12:20:37 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[Generate_Reservations]
GO
/****** Object:  StoredProcedure [dbo].[CreateCalendarTable]    Script Date: 12/19/2021 12:20:37 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[CreateCalendarTable]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Reservations]') AND type in (N'U'))
ALTER TABLE [dbo].[Reservations] DROP CONSTRAINT IF EXISTS [FK_Reservations_Visitors]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Reservations]') AND type in (N'U'))
ALTER TABLE [dbo].[Reservations] DROP CONSTRAINT IF EXISTS [FK_Reservations_Campsite]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Reservations]') AND type in (N'U'))
ALTER TABLE [dbo].[Reservations] DROP CONSTRAINT IF EXISTS [FK_Reservations_Calendar]
GO
/****** Object:  Table [dbo].[Visitors]    Script Date: 12/19/2021 12:20:37 PM ******/
DROP TABLE IF EXISTS [dbo].[Visitors]
GO
/****** Object:  View [dbo].[vw_CheckAvailableCampsiteSlots]    Script Date: 12/19/2021 12:20:38 PM ******/
DROP VIEW IF EXISTS [dbo].[vw_CheckAvailableCampsiteSlots]
GO
/****** Object:  Table [dbo].[Calendar]    Script Date: 12/19/2021 12:20:38 PM ******/
DROP TABLE IF EXISTS [dbo].[Calendar]
GO
/****** Object:  Table [dbo].[Reservations]    Script Date: 12/19/2021 12:20:38 PM ******/
DROP TABLE IF EXISTS [dbo].[Reservations]
GO
/****** Object:  Table [dbo].[Campsite]    Script Date: 12/19/2021 12:20:38 PM ******/
DROP TABLE IF EXISTS [dbo].[Campsites]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetMostPopularDayToVisit]    Script Date: 12/19/2021 12:20:38 PM ******/
DROP FUNCTION IF EXISTS [dbo].[fn_GetMostPopularDayToVisit]
GO
