USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Reportes.spGeneralNorma35_Tipo_2_3_General as
	declare
		@IDEncuesta int = 38 -- Tipo 2
			--15 --Tipo 1

	IF 1=0 BEGIN  
		SET FMTONLY OFF  
    END 
	--declare @TamanioPoblacion decimal(18,2) = 0;
	--select @TamanioPoblacion = count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = @IDEncuesta and Resultado <> 'SIN EVALUAR'

	--select @TamanioPoblacion
	
	if OBJECT_ID('tempdb..#tempEscala') is not null drop table #tempEscala;
	create table #tempEscala(
		Valor int,
		ValorLiteral varchar(20) COLLATE database_default 
	)

	insert #tempEscala
	values
			(0,'Nulo')
			,(1,'Bajo')
			,(2,'Medio')
			,(3,'Alto')
			,(4,'Muy alto')

	select 
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
		,M.Departamento
		,M.Puesto
		,M.Sucursal
		,M.Empresa as RazonSocial
		,CE.Descripcion as TipoEncuesta
		,EE.Resultado
		,C.Descripcion as CategoriaDominio
		,te.Valor		
		,te.ValorLiteral
		,CASE WHEN CCE.CalificacionLiteral = 'Nulo' THEN '#5F77FF'
							WHEN CCE.CalificacionLiteral = 'Bajo' THEN '#00C0C0'
							WHEN CCE.CalificacionLiteral = 'Medio' THEN '#FFFF00'
							WHEN CCE.CalificacionLiteral = 'Alto' THEN '#FFC000'
							WHEN CCE.CalificacionLiteral = 'Muy alto' THEN '#FF0000'
							ELSE '#5F77FF'
							END as Color
		,'Categoria' as TIPO
	from Norma35.tblEncuestasEmpleados EE 
		inner join RH.tblEmpleadosMaster M		on EE.IDEmpleado = M.IDEmpleado
		inner join Norma35.tblEncuestas E		on EE.IDEncuesta = E.IDEncuesta
		inner join Norma35.tblCatEncuestas CE	on E.IDCatEncuesta = CE.IDCatEncuesta
		inner join Norma35.tblCatGrupos G		on G.TipoReferencia = 2 
			and G.IDReferencia = EE.IDEncuestaEmpleado
		inner join Norma35.tblCatPreguntas P	on P.IDCatGrupo = G.IDCatGrupo
		inner join Norma35.tblcatCategorias C	on C.IDCategoria = P.IDCategoria
		inner join Norma35.tblRespuestasPreguntas RP on RP.IDCatPregunta = P.IDCatPregunta
		inner join Norma35.tblCalificacionCategoriaEncuestas CCE on CCE.IDCatEncuesta = E.IDCatEncuesta
			and CCE.IDCategoria = P.IDCategoria
		left join #tempEscala te on te.ValorLiteral = CCE.CalificacionLiteral
	where EE.IDEncuesta = @IDEncuesta
	group by 
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Departamento
		,M.Puesto
		,M.Sucursal
		,M.Empresa
		,CE.Descripcion
		,EE.Resultado
		,C.Descripcion 
		,CCE.CalificacionLiteral
		,CCE.Inicio
		,CCE.Fin   
		,te.Valor
		,te.ValorLiteral
	having 
		round(SUM(RP.ValorFinal),0) between CCE.Inicio and CCE.Fin
	UNION ALL
	select 
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
		,M.Departamento
		,M.Puesto
		,M.Sucursal
		,M.Empresa as RazonSocial
		,CE.Descripcion as TipoEncuesta
		,EE.Resultado
		,D.Descripcion	as CategoriaDominio
		,teD.Valor			as Valor
		,teD.ValorLiteral	as ValorLiteral
		,CASE WHEN CDE.CalificacionLiteral = 'Nulo' THEN '#5F77FF'
							WHEN CDE.CalificacionLiteral = 'Bajo' THEN '#00C0C0'
							WHEN CDE.CalificacionLiteral = 'Medio' THEN '#FFFF00'
							WHEN CDE.CalificacionLiteral = 'Alto' THEN '#FFC000'
							WHEN CDE.CalificacionLiteral = 'Muy alto' THEN '#FF0000'
							ELSE '#5F77FF'
							END as Color
		,'Dominio' as TIPO
	from Norma35.tblEncuestasEmpleados EE 
		inner join RH.tblEmpleadosMaster M		on EE.IDEmpleado = M.IDEmpleado
		inner join Norma35.tblEncuestas E		on EE.IDEncuesta = E.IDEncuesta
		inner join Norma35.tblCatEncuestas CE	on E.IDCatEncuesta = CE.IDCatEncuesta
		inner join Norma35.tblCatGrupos G		on G.TipoReferencia = 2 
			and G.IDReferencia = EE.IDEncuestaEmpleado
		inner join Norma35.tblCatPreguntas P	on P.IDCatGrupo = G.IDCatGrupo
		inner join Norma35.tblCatDominios D		on D.IDDominio = P.IDDominio
		inner join Norma35.tblRespuestasPreguntas RP on RP.IDCatPregunta = P.IDCatPregunta
		inner join  Norma35.tblCalificacionDominioEncuestas CDE on CDE.IDCatEncuesta = E.IDCatEncuesta
			and CDE.IDDominio = P.IDDominio
		left join #tempEscala teD on teD.ValorLiteral = CDE.CalificacionLiteral
	where EE.IDEncuesta = @IDEncuesta
	group by 
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Departamento
		,M.Puesto
		,M.Sucursal
		,M.Empresa
		,CE.Descripcion
		,EE.Resultado
		,D.Descripcion 
		,CDE.CalificacionLiteral
		,CDE.Inicio
		,CDE.Fin   
		,teD.Valor
		,teD.ValorLiteral
	having round(SUM(RP.ValorFinal),0) between CDE.Inicio and CDE.Fin
	--having round(SUM(RP.ValorFinal)/@TamanioPoblacion,0) between CCE.Inicio and CCE.Fin

	--select 
	--	C.Descripcion as Categoria,
	--	--SUM(RP.ValorFinal) as ValorFinal,
	--	--CCE.CalificacionLiteral,
	--	te.Valor,
	--	te.ValorLiteral,
	--	--CCE.Inicio,
	--	--CCE.Fin ,
	--	--round(SUM(RP.ValorFinal)/@TamanioPoblacion,0) F,
	--	CASE WHEN CCE.CalificacionLiteral = 'Nulo' THEN '#5F77FF'
	--						WHEN CCE.CalificacionLiteral = 'Bajo' THEN '#00C0C0'
	--						WHEN CCE.CalificacionLiteral = 'Medio' THEN '#FFFF00'
	--						WHEN CCE.CalificacionLiteral = 'Alto' THEN '#FFC000'
	--						WHEN CCE.CalificacionLiteral = 'Muy alto' THEN '#FF0000'
	--						ELSE '#5F77FF'
	--						END as Color
	----INTO #tempResult
	--from Norma35.tblEncuestasEmpleados EE 
	--	inner join Norma35.tblEncuestas E on EE.IDEncuesta = E.IDEncuesta
	--	inner join Norma35.tblCatGrupos G on G.TipoReferencia = 2 
	--		and G.IDReferencia = EE.IDEncuestaEmpleado
	--	inner join Norma35.tblCatPreguntas P on P.IDCatGrupo = G.IDCatGrupo
	--	inner join Norma35.tblcatCategorias C on C.IDCategoria = P.IDCategoria
	--	Inner join Norma35.tblRespuestasPreguntas RP on RP.IDCatPregunta = P.IDCatPregunta
	--	inner join Norma35.tblCalificacionCategoriaEncuestas CCE on CCE.IDCatEncuesta = E.IDCatEncuesta
	--		and CCE.IDCategoria = P.IDCategoria
	--	inner join #tempEscala te on te.ValorLiteral = CCE.CalificacionLiteral
	--where EE.IDEncuesta = @IDEncuesta
	--Group by  C.Descripcion 
	--		,CCE.CalificacionLiteral
	--		,CCE.Inicio
	--	   ,CCE.Fin   
	--	   ,te.Valor
	--	   ,te.ValorLiteral
	--having round(SUM(RP.ValorFinal)/@TamanioPoblacion,0) between CCE.Inicio and CCE.Fin
GO
