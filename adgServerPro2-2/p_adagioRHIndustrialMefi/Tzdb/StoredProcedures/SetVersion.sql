USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tzdb].[SetVersion]
	@Version char(5)
AS
DELETE FROM [Tzdb].[VersionInfo]
INSERT INTO [Tzdb].[VersionInfo] ([Version],[Loaded]) VALUES (@Version, GETUTCDATE())
GO
