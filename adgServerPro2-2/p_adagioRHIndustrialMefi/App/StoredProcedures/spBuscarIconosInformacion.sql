USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [App].[spBuscarIconosInformacion](
	@Url varchar(max)
	,@IDUsuario int  
) as


	select @Url=lower(
			SUBSTRING(@url,
				CHARINDEX('/',@Url) +1,
					case when CHARINDEX('?',@Url) > 0 then CHARINDEX('?',@Url) - CHARINDEX('/',@Url) -1 else len(@url) end)
		)

		SELECT * FROM app.tblIconosInformacion
		WHERE (lower([Url]) = lower(@Url)) or (lower([Url]) = lower(@Url)+'/index')
GO
