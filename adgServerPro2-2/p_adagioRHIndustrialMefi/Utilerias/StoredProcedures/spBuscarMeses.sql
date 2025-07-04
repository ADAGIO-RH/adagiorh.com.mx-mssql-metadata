USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Utilerias].[spBuscarMeses](
	@IDUsuario int = 0
)
as

	declare  
		@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	SET DATEFIRST 7;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;


	select IDMes
		,DATENAME(month, '1900-'+case when IDMes >= 10 then cast(IDMes as varchar) else '0'+cast(IDMes as varchar) end+'-01') AS Nombre
	from  Utilerias.tblMeses
GO
