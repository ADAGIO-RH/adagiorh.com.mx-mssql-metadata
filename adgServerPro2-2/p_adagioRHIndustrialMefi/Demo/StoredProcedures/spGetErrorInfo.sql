USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Demo].[spGetErrorInfo]  
AS  

	insert Demo.tblLogActividades(Error,Mensaje)
	SELECT  
		1
		,'ErrorProcedure ' + ERROR_PROCEDURE()+char(10)
		 +'ErrorLine ' + cast(ERROR_LINE() as varchar)+char(10)
		 +'ErrorMessage' + ERROR_MESSAGE()
GO
