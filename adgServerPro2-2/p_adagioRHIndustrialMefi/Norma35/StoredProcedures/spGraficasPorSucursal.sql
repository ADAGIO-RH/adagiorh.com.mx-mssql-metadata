USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spGraficasPorSucursal]-- 9
(
	@IDEncuesta int,
    @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    @IDUsuario int 
)
AS
--declare 	@IDEncuesta int  =22
BEGIN
	  IF 1=0 BEGIN  
       SET FMTONLY OFF  
     END  
	if OBJECT_ID('tempdb..#tempEscala') is not null drop table #tempEscala;
	if OBJECT_ID('tempdb..#tempResult') is not null drop table #tempResult;
	if OBJECT_ID('tempdb..#tempPoblacion') is not null drop table #tempPoblacion;

    DECLARE
            @dtEmpleados [RH].[dtEmpleados]
 

	INSERT INTO @dtEmpleados    
	EXEC [RH].[spBuscarEmpleadosMaster] 
			 @dtFiltros =@dtFiltros
			,@IDUsuario		= @IDUsuario 

	create table #tempPoblacion(
		Sucursal Varchar(255) COLLATE database_default ,
		Qty int
	)

	insert into #tempPoblacion
	Select M.Sucursal, count(*)
	from Norma35.tblEncuestasEmpleados EE
		inner join RH.tblEmpleadosMaster M
			on EE.IDEmpleado = M.IDEmpleado
             Inner join  @dtEmpleados dtE 
             on EE.IDEmpleado = dtE.IDEmpleado
	where EE.IDEncuesta = @IDEncuesta 
	and EE.Resultado <> 'SIN EVALUAR'
	Group by M.Sucursal

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

	Select M.Sucursal as Sucursal,
		   --SUM(RP.ValorFinal) as ValorFinal,
		   --CCE.CalificacionLiteral,
		  CASE WHEN E.IDCatEncuesta = 2 THEN CASE WHEN SUM(rp.ValorFinal)/pd.Qty between 0 and 19 THEN 'NULO'
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 20 and 44 THEN 'BAJO'
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 45 and 69 THEN 'MEDIO'
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 70 and 89 THEN 'ALTO'
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 90 and 9999 THEN 'MUY ALTO'
								ELSE 'NULO'
								END 
			   ELSE
			   CASE WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 0 and 49 THEN 'NULO'
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 50 and 74 THEN 'BAJO'
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 75 and 98 THEN 'MEDIO'
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 99 and 139 THEN 'ALTO'
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 140 and 9999 THEN 'MUY ALTO'
									ELSE 'NULO'
									END
			   END	as ValorLiteral,
		  
		  
			CASE WHEN E.IDCatEncuesta = 2 THEN	CASE WHEN SUM(rp.ValorFinal)/pd.Qty between 0 and 19 THEN 0
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 20 and 44 THEN 1
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 45 and 69 THEN 2
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 70 and 89 THEN 3
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 90 and 9999 THEN 4
								ELSE 0
								END 
				ELSE 
				 CASE WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 0 and 49 THEN 0
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 50 and 74 THEN 1
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 75 and 98 THEN 2
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 99 and 139 THEN 3
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 140 and 9999 THEN 4
									ELSE 0
									END
				END as Valor,
		   --CCE.Inicio,
		   --CCE.Fin ,
		  CASE WHEN E.IDCatEncuesta = 2 THEN CASE WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 0 and 19  THEN '#5F77FF'
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 20 and 44 THEN '#00C0C0'
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 45 and 69 THEN '#FFFF00'
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 70 and 89 THEN '#FFC000'
								WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 90 and 9999 THEN '#FF0000'
								ELSE '#5F77FF'
								END 
				ELSE
					CASE WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 0 and 49 THEN '#5F77FF'
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 50 and 74 THEN '#00C0C0'
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 75 and 98 THEN '#FFFF00'
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 99 and 139 THEN '#FFC000'
									WHEN ROUND(SUM(rp.ValorFinal)/pd.Qty,0) between 140 and 9999 THEN '#FF0000'
									ELSE '#5F77FF'
									END
				END as Color
								
				
	INTO #tempResult
	from Norma35.tblEncuestasEmpleados EE 
		inner join RH.tblEmpleadosMaster M
			on EE.IDEmpleado = M.IDEmpleado
		inner join Norma35.tblEncuestas E
			on EE.IDEncuesta = E.IDEncuesta
		inner join Norma35.tblCatGrupos G
			on G.TipoReferencia = 2 
				and G.IDReferencia = EE.IDEncuestaEmpleado
		inner join Norma35.tblCatPreguntas P
			on P.IDCatGrupo = G.IDCatGrupo
		Inner join Norma35.tblRespuestasPreguntas RP
			on RP.IDCatPregunta = P.IDCatPregunta
		inner join #tempPoblacion PD
			on PD.Sucursal = M.Sucursal
            Inner join  @dtEmpleados dtE 
             on EE.IDEmpleado = dtE.IDEmpleado
	where EE.IDEncuesta = @IDEncuesta
	Group by  M.Sucursal ,pd.Qty,E.IDCatEncuesta
	

	select *
	from (
		select *
		from #tempResult
		
	) as r
	order by Valor 
END
GO
