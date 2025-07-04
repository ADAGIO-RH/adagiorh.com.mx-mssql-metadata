USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc App.spListaFechasWithFechaStr (
	@FechaIni date
	,@FechaFin date
	,@IDUsuario int
) as
	declare
		@dtFechas app.dtFechas
		,@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null   
	;

	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u with (nolock)
		Inner join App.tblPreferencias p  with (nolock) 
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp with (nolock)  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp with (nolock)  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas with (nolock)  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish';  
	end  
    
	SET LANGUAGE @IdiomaSQL; 
	SET DATEFIRST 7;  
	SET DATEFORMAT ymd;

	insert into @dtFechas  
	exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin 

	select
		Fecha,
		upper(Format(Fecha, 'dddd dd  MMM')) as FechaStr
	from @dtFechas
GO
