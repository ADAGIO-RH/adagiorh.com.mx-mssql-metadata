USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarMisAprobacionesPendientesPlazas] (
	@IDUsuario int
) as
        DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if OBJECT_ID('tempdb..#tempAprobadores') is not null drop table #tempAprobadores;
    if OBJECT_ID('tempdb..#tempAprobadoresRechazados') is not null drop table #tempAprobadoresRechazados;

	select * ,ROW_NUMBER()OVER(Partition by IDPlaza order by Orden asc)RN
	into #tempAprobadores
	from RH.tblAprobadoresPlazas ap
	where ap.Aprobacion = 0
		and ap.Secuencia = (select max(Secuencia) from RH.tblAprobadoresPlazas where IDPlaza = ap.IDPlaza)
   

	select * ,ROW_NUMBER()OVER(Partition by IDPlaza order by Orden asc)RN
	into #tempAprobadoresRechazados
	from RH.tblAprobadoresPlazas ap
	where ap.Aprobacion = 2
		and ap.Secuencia = (select max(Secuencia) from RH.tblAprobadoresPlazas where IDPlaza = ap.IDPlaza)

	Select 
		(
			select top 1 IDAprobadorPlaza from #tempAprobadores where RN = 1 and IDUsuario = @IDUsuario
		) as IDAprobadorPlaza
		,p.IDPlaza
		,p.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,p.Codigo
		,JSON_VALUE(pu.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Nombre 
		,p.ParentId
		,p.TotalPosiciones	 
		,p.PosicionesOcupadas		
		,p.PosicionesDisponibles
	from [RH].[tblCatPlazas] p with (nolock)
		join [RH].[tblCatClientes] c with (nolock) on c.IDCliente = p.IDCliente
		 inner join rh.tblCatPuestos pu on p.IDPuesto=p.IDPuesto
	where IDPlaza in (
			select IDPlaza from #tempAprobadores where RN = 1 and IDUsuario = @IDUsuario
		)
		and IDPlaza not in (
			select IDPlaza from #tempAprobadoresRechazados
		)

	if OBJECT_ID('tempdb..#tempAprobadores') is not null drop table #tempAprobadores;
    if OBJECT_ID('tempdb..#tempAprobadoresRechazados') is not null drop table #tempAprobadoresRechazados;
GO
