USE [readOnly_adagioRHHotelesGDLPlaza]
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
0000-00-00  NombreCompleto  ¿Qué cambió?  
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
	@FechaInicioAnio date
	   ; 

	 --insert @saldosVacaciones  
	 --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado,1
  

	 -- select top 1 @FechaInicialAnio = FechaIni from @saldosVacaciones 
	 --ORDER BY Anio desc 
      
	 set @FechaInicioAnio = cast(DATEPART(year,@FechaFin)as varchar(4))+'-01-01';
	 set @Dias = DATEDIFF(day,CASE WHEN @FechaIni < @FechaInicioAnio then @FechaInicioAnio else @FechaIni end,@FechaFin) +1  
  
	  Select @Antiguedad = Cast(DATEDIFF(DAY,@FechaIni  ,@FechaFin) as decimal)/365.0    
    
	 Select top 1 @DiasAguinaldoProp = ((CAST(DiasAguinaldo as decimal)/365.0) * @Dias)    
	 from [RH].[tblCatTiposPrestacionesDetalle]    
	 where IDTipoPrestacion = @IDTipoPrestacion    
	  and Antiguedad >= case when @Antiguedad < 1 then 1 Else @Antiguedad END    
	 ORDER BY Antiguedad ASC    
    
	 select  @DiasAguinaldoProp as Saldo;    


END
GO
