USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Intranet].[spDeduccionesPorMes](
	@Ejercicio int =0,
	@IDMes int = 0,
	@IDEmpleado int = 0,
	@IDUsuario int
) as 
Begin
	declare  
		@IDIdioma varchar(225),
		@QueryDeducciones NVarchar(MAX),
		@IDPais int,
		@ID_PAIS_MEXICO int = 151
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if OBJECT_ID('tempdb..#tempRespuesta') is not null drop table #tempRespuesta;

	DECLARE @IDsConceptosDeducciones as Table (
		IDConcepto int
	);

	Select top 1 @IDPais = TN.IDPais
	from RH.tblEmpleadosMaster M with(nolock)
		inner join Nomina.tblCatTipoNomina TN with(nolock)
			on TN.IDTipoNomina = m.IDTipoNomina
	where IDEmpleado = @IDEmpleado

	SELECT @QueryDeducciones = Filtro 
	FROM Intranet.tblConfigDashboardNomina with(nolock)
	WHERE isnull(IDPais, @ID_PAIS_MEXICO) = @IDPais
	and BotonLabel in ( 'Deducciones')

	INSERT INTO @IDsConceptosDeducciones
	EXEC sp_executesql @QueryDeducciones

	select dp.ImporteTotal1 as TotalDeducciones,
			--M.Descripcion
			JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
	INTO #tempRespuesta
	from Nomina.tblCatMeses m
		left join Nomina.tblCatPeriodos P with (nolock) on m.IDMes = p.IDMes
		join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDPeriodo = P.IDPeriodo and DP.IDEmpleado = @IDEmpleado
		join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.IDConcepto in (Select IDConcepto from @IDsConceptosDeducciones)--c.Codigo = '560'
	where (p.Ejercicio = @Ejercicio or @Ejercicio=0 ) 
	  and (p.IDMes = @IDMes or @IDMes = 0) 
	  and isnull(p.Cerrado, 0) = 1

	select Descripcion, SUM(TotalDeducciones) as TotalDeducciones
	from #tempRespuesta
	group by Descripcion
END
GO
