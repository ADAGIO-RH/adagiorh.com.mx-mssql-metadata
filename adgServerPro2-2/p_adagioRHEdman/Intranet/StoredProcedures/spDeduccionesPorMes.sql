USE [p_adagioRHEdman]
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
) as Begin
	declare  
		@IDIdioma varchar(225)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if OBJECT_ID('tempdb..#tempRespuesta') is not null drop table #tempRespuesta;

	select dp.ImporteTotal1 as TotalDeducciones,
			--M.Descripcion
			JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
	INTO #tempRespuesta
	from Nomina.tblCatMeses m
		left join Nomina.tblCatPeriodos P with (nolock) on m.IDMes = p.IDMes
		join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDPeriodo = P.IDPeriodo and DP.IDEmpleado = @IDEmpleado
		join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo = '560'
	where (p.Ejercicio = @Ejercicio or @Ejercicio=0 ) 
	  and (p.IDMes = @IDMes or @IDMes = 0) 
	  and isnull(p.Cerrado, 0) = 1

	select Descripcion, SUM(TotalDeducciones) as TotalDeducciones
	from #tempRespuesta
	group by Descripcion

END
GO
