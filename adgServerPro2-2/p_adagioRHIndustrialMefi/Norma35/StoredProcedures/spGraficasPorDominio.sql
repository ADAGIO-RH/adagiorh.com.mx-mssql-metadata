USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Norma35].[spGraficasPorDominio] 
(
	       @IDEncuesta int,   
    @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    @IDUsuario int 
)
AS

BEGIN
	  IF 1=0 BEGIN  
       SET FMTONLY OFF  
     END  
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

	Select C.Descripcion as Dominio,		 
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
		inner join Norma35.tblCatDominios C
			on C.IDDominio = P.IDDominio
		Inner join Norma35.tblRespuestasPreguntas RP
			on RP.IDCatPregunta = P.IDCatPregunta
		inner join  Norma35.tblCalificacionDominioEncuestas CCE
			on CCE.IDCatEncuesta = E.IDCatEncuesta
			and CCE.IDDominio = P.IDDominio
		inner join #tempEscala te on te.ValorLiteral = CCE.CalificacionLiteral
        Inner join  @dtEmpleados dtE on EE.IDEmpleado = dtE.IDEmpleado
	where EE.IDEncuesta = @IDEncuesta
	Group by  C.Descripcion 
			,CCE.CalificacionLiteral
			,CCE.Inicio
		   ,CCE.Fin   
		   ,te.Valor
		   ,te.ValorLiteral
	having ROUND(SUM(RP.ValorFinal)/NULLIF(@TamanioPoblacion, 0),0) between CCE.Inicio and CCE.Fin


	select *
	from (
		select *
		from #tempResult
		
	) as r
	order by Valor 
END
GO
