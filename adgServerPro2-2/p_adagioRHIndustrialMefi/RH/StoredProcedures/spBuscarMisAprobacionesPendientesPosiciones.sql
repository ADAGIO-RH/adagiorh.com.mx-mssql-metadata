USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarMisAprobacionesPendientesPosiciones] (
	@IDUsuario int
) as

  DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if OBJECT_ID('tempdb..#tempAprobadores') is not null drop table #tempAprobadores;
    if OBJECT_ID('tempdb..#tempAprobadoresRechazados') is not null drop table #tempAprobadoresRechazados;

	select * ,ROW_NUMBER()OVER(Partition by IDPosicion order by Orden asc)RN
	into #tempAprobadores
	from RH.tblAprobadoresPosiciones ap
	where ap.Aprobacion = 0
		and ap.Secuencia = (select max(Secuencia) from RH.tblAprobadoresPosiciones where IDPosicion = ap.IDPosicion)
   

	select * ,ROW_NUMBER()OVER(Partition by IDPosicion order by Orden asc)RN
	into #tempAprobadoresRechazados
	from RH.tblAprobadoresPosiciones ap
	where ap.Aprobacion = 2
		and ap.Secuencia = (select max(Secuencia) from RH.tblAprobadoresPosiciones where IDPosicion = ap.IDPosicion)

	Select
		(
			select top 1 IDAprobadorPosicion from #tempAprobadores where RN = 1 and IDUsuario = @IDUsuario
		) as IDAprobadorPosicion
		,p.IDPosicion
		,p.IDPlaza
		,p.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,p.Codigo
		,pa.Codigo as CodigoPlaza
		,JSON_VALUE(pu.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Plaza
	from [RH].[tblCatPosiciones] p with (nolock)
		join RH.tblCatPlazas pa on pa.IDPlaza = p.IDPlaza
		join [RH].[tblCatClientes] c with (nolock) on c.IDCliente = p.IDCliente
		 inner join rh.tblCatPuestos pu on pa.IDPuesto=pu.IDPuesto
	where IDPosicion in (
			select IDPosicion from #tempAprobadores where RN = 1 and IDUsuario = @IDUsuario
		)
		and IDPosicion not in (
			select IDPosicion from #tempAprobadoresRechazados
		)

	if OBJECT_ID('tempdb..#tempAprobadores') is not null drop table #tempAprobadores;
    if OBJECT_ID('tempdb..#tempAprobadoresRechazados') is not null drop table #tempAprobadoresRechazados;
GO
