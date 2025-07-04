USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar en la [Dashboard].[tblHistorialVigenciasPorFechas] por fechas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-09
** Paremetros		:              


	exec [Dashboard].[spBuscarHistorialVigenciasPorFechas] @FechaIni='2020-08-01', @FechaFin='2022-08-25', @IDUsuario=1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Dashboard].[spBuscarHistorialVigenciasPorFechas](
     @FechaIni date
    ,@FechaFin date
    ,@IDUsuario int
) as
    declare 
		@IDIdioma varchar(10)
	   ,@IdiomaSQL varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = i.[SQL]
	from App.tblIdiomas i
	where i.IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;

    select 
	   Fecha
	   ,LEFT(DATENAME(WEEKDAY,Fecha),3) + ' ' +
		  CONVERT(VARCHAR(6),Fecha,106) FechaStr
	   ,Total
    from [Dashboard].[tblHistorialVigenciasPorFechas] with (nolock)
    where Fecha BETWEEN @FechaIni and @FechaFin
GO
