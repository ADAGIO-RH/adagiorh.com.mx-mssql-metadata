USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Dashboard].[spHistorialDePruebas](
	@FechaIni date,
	@FechaFin date,
	@IDUsuario int
) as
	--declare 
	--	@FechaIni date = '2020-06-01',
	--	@FechaFin date = '2020-06-30',
	--	@IDUsuario int = 1
	--;

	declare 
		@IDPreferencia int = 0
	   ,@IDIdioma varchar(10)
	   ,@Fechas [App].[dtFechas]
	;

	insert into @Fechas(Fecha)
	exec [App].[spListaFechas]
		@FechaIni = @FechaIni
		,@FechaFin = @FechaFin

    select @IDPreferencia = isnull(IDPreferencia,0)
    from [Seguridad].[tblUsuarios] with (nolock)
    where IDUsuario = @IDUsuario
    
    if (@IDPreferencia > 0)
    begin
		select @IDIdioma= i.[SQL]
		from App.tblDetallePreferencias dp with (nolock)
			join App.tblIdiomas i with (nolock) on i.IDIdioma =  dp.Valor
		where dp.IDPreferencia = @IDPreferencia and dp.IDTipoPreferencia = 1 /* La preferencia Idioma es el IDPreferencia 1*/
	   
		SET Language @IDIdioma;
    end else
    begin
		SET Language 'Spanish';
    end

	if OBJECT_ID('tempdb..#tempHistorialPruebas') is not null drop table #tempHistorialPruebas;

	select 
		f.Fecha
		,LEFT(DATENAME(WEEKDAY,f.Fecha),3)+ ' ' +CONVERT(VARCHAR(6),f.Fecha,106) FechaStr
		,Nombre = case when isnull(d.Total,0) > 0 then 
							coalesce(d.Prueba,'')+'-'+coalesce(d.Cuestionario,'')
						else 'NINGUNA' end
		,isnull(d.Total,0) as Total
	INTO #tempHistorialPruebas
	from @Fechas f
		left join (
			select 
				--pe.IDPruebaEmpleado
				--,pe.IDPrueba
				--,pe.FechaCreacion
				--,
				p.Nombre as Prueba
				,c.Nombre as Cuestionario
				--,LEFT(DATENAME(WEEKDAY,pe.FechaCreacion),3) + ' ' +CONVERT(VARCHAR(6),pe.FechaCreacion,106) FechaStr
				,CAST(pe.FechaCreacion as Date) as Fecha
				,COUNT(*) as Total
			from Salud.tblPruebasEmpleados pe with (nolock)
				join Salud.tblPruebas p with (nolock) on p.IDPrueba = pe.IDPrueba
				join Salud.tblCuestionariosEmpleados ce with (nolock) on pe.IDPruebaEmpleado = ce.IDPruebaEmpleado
				join Salud.tblCuestionarios c with (nolock) on c.IDReferencia = ce.IDCuestionarioEmpleado and c.TipoReferencia = 2
			where CAST(pe.FechaCreacion as date) between @FechaIni and @FechaFin
			group by p.Nombre, c.Nombre,CAST(pe.FechaCreacion as Date)
		) d on d.Fecha = f.Fecha
	order by f.Fecha asc

	select * from #tempHistorialPruebas

	select distinct(Nombre) as Nombre 
	from #tempHistorialPruebas
	where Nombre <> 'NINGUNA'
GO
