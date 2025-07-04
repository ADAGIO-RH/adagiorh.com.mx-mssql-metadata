USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spEncabezadoReporteGeneralFRPGrafica] --22
(
	@IDEncuesta int
)
AS
BEGIN

Declare @IdiomaSQL varchar(50)
	set @IdiomaSQL = 'Spanish' ;
	SET LANGUAGE @IdiomaSQL; 

DECLARE @TamanioPoblacion decimal(18,2) = 0,
		@PorcentajeRealizado decimal(18,2),
		@SinAcontecimiento int = 0,
		@ConAcontecimiento int = 0,
		@CantidadContesto decimal(18,2) = 0 ,
		@ResultadoGeneralLiteral int = 0,
		@ResultadoGeneral Varchar(50) = '',
		@IDCatEncuesta int = 0,
		@Color Varchar(50) = '';


	Select @TamanioPoblacion = count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = @IDEncuesta
	Select @CantidadContesto = count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = @IDEncuesta and Resultado <> 'SIN EVALUAR'
	Select @PorcentajeRealizado = case when @CantidadContesto = 0.0 then 0 else  (@CantidadContesto / @TamanioPoblacion ) * 100 END
	select @IDCatEncuesta = IDCatEncuesta from Norma35.tblEncuestas where IDEncuesta = @IDEncuesta

	Select @ResultadoGeneralLiteral = CASE WHEN @CantidadContesto = 0 then 0 else round(SUM(RP.ValorFinal) / @CantidadContesto,0) END 
	from Norma35.tblEncuestasEmpleados EE 
		inner join Norma35.tblCatGrupos G
			on G.TipoReferencia = 2 
				and G.IDReferencia = EE.IDEncuestaEmpleado
		inner join Norma35.tblCatPreguntas P
			on P.IDCatGrupo = G.IDCatGrupo
		Inner join Norma35.tblRespuestasPreguntas RP
			on RP.IDCatPregunta = P.IDCatPregunta
	where EE.IDEncuesta = @IDEncuesta

	if (@IDCatEncuesta = 2)
	begin
		set @ResultadoGeneral = CASE WHEN @ResultadoGeneralLiteral between 0 and 19 THEN 'NULO'
									WHEN @ResultadoGeneralLiteral between 20 and 44 THEN 'BAJO'
									WHEN @ResultadoGeneralLiteral between 45 and 69 THEN 'MEDIO'
									WHEN @ResultadoGeneralLiteral between 70 and 89 THEN 'ALTO'
									WHEN @ResultadoGeneralLiteral between 90 and 9999 THEN 'MUY ALTO'
									ELSE 'NULO'
									END
	   set @Color = CASE WHEN @ResultadoGeneralLiteral between 0 and 19 THEN '#5F77FF'
									WHEN @ResultadoGeneralLiteral between 20 and 44 THEN '#00C0C0'
									WHEN @ResultadoGeneralLiteral between 45 and 69 THEN '#FFFF00'
									WHEN @ResultadoGeneralLiteral between 70 and 89 THEN '#FFC000'
									WHEN @ResultadoGeneralLiteral between 90 and 9999 THEN '#FF0000'
									ELSE '#5F77FF'
									END

	end else
	if (@IDCatEncuesta = 3)
	begin
		set @ResultadoGeneral = CASE WHEN @ResultadoGeneralLiteral between 0 and 49 THEN 'NULO'
									WHEN @ResultadoGeneralLiteral between 50 and 74 THEN 'BAJO'
									WHEN @ResultadoGeneralLiteral between 75 and 98 THEN 'MEDIO'
									WHEN @ResultadoGeneralLiteral between 99 and 139 THEN 'ALTO'
									WHEN @ResultadoGeneralLiteral between 140 and 9999 THEN 'MUY ALTO'
									ELSE 'NULO'
									END
	   set @Color = CASE WHEN @ResultadoGeneralLiteral between 0 and 49 THEN '#5F77FF'
									WHEN @ResultadoGeneralLiteral between 50  and 74 THEN '#00C0C0'
									WHEN @ResultadoGeneralLiteral between 75  and 98 THEN '#FFFF00'
									WHEN @ResultadoGeneralLiteral between 99  and 139 THEN '#FFC000'
									WHEN @ResultadoGeneralLiteral between 140 and 9999 THEN '#FF0000'
									ELSE '#5F77FF'
									END
	end;

	Select 
		 E.NombreEncuesta
		 ,E.FechaIni
		 ,E.FechaFin
		 ,CE.Nombre as TipoEncuesta
		,@TamanioPoblacion as TamanioPoblacion
		,@PorcentajeRealizado as PorcentajeRealizado
		,@CantidadContesto as CantidadContesto
		,@ResultadoGeneralLiteral as ResultadoGeneralLiteral
		,@ResultadoGeneral as ResultadoGeneral
		,@Color as Color
	FROM Norma35.tblEncuestas e
		inner join Norma35.tblCatEncuestas CE
			on CE.IDCatEncuesta = e.IDCatEncuesta
	where e.IDEncuesta = @IDEncuesta
END;
GO
