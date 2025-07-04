USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spEncabezadoReporteGeneralATSGrafica] --22
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
		@RequiereAtencion int = 0,
		@CantidadContesto decimal(18,2) = 0 ;


	Select @TamanioPoblacion = count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = @IDEncuesta
	Select @CantidadContesto = count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = @IDEncuesta and Resultado <> 'SIN EVALUAR'
	Select @PorcentajeRealizado = case when @CantidadContesto = 0.0 then 0 else  (@CantidadContesto / @TamanioPoblacion ) * 100 END
	SELECT @ConAcontecimiento = count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = @IDEncuesta and Resultado = 'CON ACONTECIMIENTO'
	SELECT @SinAcontecimiento = count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = @IDEncuesta and Resultado = 'SIN ACONTECIMIENTO'
	SELECT @RequiereAtencion = count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = @IDEncuesta and RequiereAtencion = 'SI'



	Select 
		 E.NombreEncuesta
		 ,E.FechaIni
		 ,E.FechaFin
		 ,CE.Nombre as TipoEncuesta
		,@TamanioPoblacion as TamanioPoblacion
		,@PorcentajeRealizado as PorcentajeRealizado
		,@ConAcontecimiento as ConAcontecimiento
		,@SinAcontecimiento as SinAcontecimiento
		,@CantidadContesto as CantidadContesto
		,@RequiereAtencion as RequiereAtencion
	FROM Norma35.tblEncuestas e
		inner join Norma35.tblCatEncuestas CE
			on CE.IDCatEncuesta = e.IDCatEncuesta
	where e.IDEncuesta = @IDEncuesta
END;
GO
