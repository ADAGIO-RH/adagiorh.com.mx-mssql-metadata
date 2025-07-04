USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [App].[spValidarBrowser](
	 @IDBrowser	varchar(50)
	,@MinVersion	float
	,@Plataforma	varchar(100)
	,@SO	varchar(100)
) as

	declare @esCompatible bit = 0;

	if exists(select top 1 1
				from app.TblBrowserCompatibles
				where	 IDBrowser	 = @IDBrowser
						and MinVersion	 <= @MinVersion
						and Plataforma	 = @Plataforma
						and SO			 = @SO
		) 
	Begin
		set @esCompatible = 1;
	end;


	--select @esCompatible as esCompatible
	select cast(1 as bit) as esCompatible
GO
