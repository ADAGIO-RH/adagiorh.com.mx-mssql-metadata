USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [AdagioSecurity].spCreateDeveloperDataBaseRole as
	CREATE ROLE [developer]
GO
