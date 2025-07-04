USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
/****************************************************************************************************   
** Descripción  : Procedimiento para obtener los Dias de Aguinaldo Proporcionales  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 16-08-2018  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2023-11-22			Juan C. Verdugo		Se agregó una configuración para descontar Incapacidades e Incidencias en base a una configuracion
										de Nominas.  
2024-02-14			Julio Castillo		La configuracion ya se agregó al catálogo de configuraciones de nómina. Si la configuración no tiene valores, lo sigue haciendo de forma default.
***************************************************************************************************/  
--select * from RH.tblEmpleados where IDEmpleado = 20314  
--select * from RH.tblCatTiposPrestaciones  
  
CREATE PROCEDURE [Asistencia].[spBuscarBuscarDiasAguinaldoProporcionales] --20314,1,'2018-06-21','2018-08-16'  
(  
 @IDEmpleado int,  
 @IDTipoPrestacion int,  
 @FechaIni Date,  
 @FechaFin Date   
)  
AS  
BEGIN  
 --select Asistencia.fnBuscarDiasAguinaldoProporcionales( @IDEmpleado,@IDTipoPrestacion,@FechaIni,@FechaFin) as Saldo  

  DECLARE     
    @Antiguedad decimal(18,2),     
    @DiasAguinaldoProp decimal(18,2) = 0,  
	@FechaInicialAnio Date,  
	@Dias int,
	@saldosVacaciones [Asistencia].[dtSaldosDeVacaciones],
	@FechaInicioAnio date,
	@IDIncidencias varchar(MAX),
	@IDIncapacidades varchar(MAX),
	@Ausentismos int,
	@Incapacidades int
	; 

	 --insert @saldosVacaciones  
	 --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado,1
  

	 -- select top 1 @FechaInicialAnio = FechaIni from @saldosVacaciones 
	 --ORDER BY Anio desc 

	 set @FechaInicioAnio = cast(DATEPART(year,@FechaFin)as varchar(4))+'-01-01';

	 SELECT @IDIncidencias = ISNULL(Valor,'') FROM Nomina.tblConfiguracionNomina WHERE Configuracion = 'INCIDENCIASADESCONTARDIASAGUINALDO'
	 SELECT @IDIncapacidades = ISNULL(Valor,'') FROM Nomina.tblConfiguracionNomina WHERE Configuracion = 'INCAPACIDADESADESCONTARDIASAGUINALDO'

	 SELECT @Ausentismos = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,@IDIncidencias,(CASE WHEN @FechaIni < @FechaInicioAnio THEN @FechaInicioAnio ELSE @FechaIni END),@FechaFin)
	 SELECT @Incapacidades = [Asistencia].[fnBuscarIncapacidadEmpleado](@IDEmpleado,@IDIncapacidades,(CASE WHEN @FechaIni < @FechaInicioAnio THEN @FechaInicioAnio ELSE @FechaIni END),@FechaFin)


	 set @Dias = DATEDIFF(day,CASE WHEN @FechaIni < @FechaInicioAnio then @FechaInicioAnio else @FechaIni end,@FechaFin) - ( isnull(@Ausentismos,0) + isnull(@Incapacidades,0) ) + 1

	 Select @Antiguedad = Cast(DATEDIFF(DAY,@FechaIni  ,@FechaFin) as decimal)/365.0    
    
	 Select top 1 @DiasAguinaldoProp = ((CAST(DiasAguinaldo as decimal)/365.0) * @Dias)    
	 from [RH].[tblCatTiposPrestacionesDetalle]    
	 where IDTipoPrestacion = @IDTipoPrestacion    
	  and Antiguedad >= case when @Antiguedad < 1 then 1 Else @Antiguedad END    
	 ORDER BY Antiguedad ASC    
    
	 select @DiasAguinaldoProp as Saldo;    


END
GO
