USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Norma35].[spGraficasPorCategoria] (
        @IDEncuesta int,   
    @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    @IDUsuario int 
)
AS 
BEGIN
	if OBJECT_ID('tempdb..#tempEscala') is not null drop table #tempEscala;
	if OBJECT_ID('tempdb..#tempResult') is not null drop table #tempResult;

    DECLARE
            @dtEmpleados [RH].[dtEmpleados]
 

	INSERT INTO @dtEmpleados    
	EXEC [RH].[spBuscarEmpleadosMaster] 
			 @dtFiltros =@dtFiltros
			,@IDUsuario		= @IDUsuario 



	declare @TamanioPoblacion decimal(18,2) = 0;  
	Select @TamanioPoblacion = count(*) from Norma35.tblEncuestasEmpleados EE  Inner join  @dtEmpleados dtE on EE.IDEmpleado = dtE.IDEmpleado  where EE.IDEncuesta = @IDEncuesta and Resultado <> 'SIN EVALUAR'

	create table #tempEscala(
		Valor int,
		ValorLiteral varchar(20) COLLATE database_default 
	)

	insert #tempEscala
	values(0,'Nulo')
		 ,(1,'Bajo')
		 ,(2,'Medio')
		 ,(3,'Alto')
		 ,(4,'Muy alto')

	Select C.Descripcion as Categoria,	
		   te.Valor,
		   te.ValorLiteral,	
		   CASE WHEN CCE.CalificacionLiteral = 'Nulo' THEN '#5F77FF'
								WHEN CCE.CalificacionLiteral = 'Bajo' THEN '#12C611'
								WHEN CCE.CalificacionLiteral = 'Medio' THEN '#FFFF00'
								WHEN CCE.CalificacionLiteral = 'Alto' THEN '#FFC000'
								WHEN CCE.CalificacionLiteral = 'Muy alto' THEN '#FF0000'
								ELSE '#5F77FF'
								END as Color
	INTO #tempResult
	from Norma35.tblEncuestasEmpleados EE 
		inner join Norma35.tblEncuestas E
			on EE.IDEncuesta = E.IDEncuesta
		inner join Norma35.tblCatGrupos G
			on G.TipoReferencia = 2 
				and G.IDReferencia = EE.IDEncuestaEmpleado
		inner join Norma35.tblCatPreguntas P
			on P.IDCatGrupo = G.IDCatGrupo
		inner join Norma35.tblcatCategorias C
			on C.IDCategoria = P.IDCategoria
		Inner join Norma35.tblRespuestasPreguntas RP
			on RP.IDCatPregunta = P.IDCatPregunta
		inner join  Norma35.tblCalificacionCategoriaEncuestas CCE
			on CCE.IDCatEncuesta = E.IDCatEncuesta
			and CCE.IDCategoria = P.IDCategoria
		inner join #tempEscala te on te.ValorLiteral = CCE.CalificacionLiteral
               Inner join  @dtEmpleados dtE on EE.IDEmpleado = dtE.IDEmpleado
            WHERE EE.IDEncuesta = @IDEncuesta   
	Group by  C.Descripcion 
			,CCE.CalificacionLiteral
			,CCE.Inicio
		   ,CCE.Fin   
		   ,te.Valor
		   ,te.ValorLiteral
	having round(SUM(RP.ValorFinal)/NULLIF(@TamanioPoblacion, 0),0) between CCE.Inicio and CCE.Fin


	select *
	from (
		select *
		from #tempResult	
	) as r
	order by Valor 

END
GO
