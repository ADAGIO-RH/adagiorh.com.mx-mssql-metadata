USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para obtener las vacaciones pentientes por Tomar de un Empleado  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 16-08-2018  
** Paremetros  :                
  select * from RH.tblEmpleadosMAster where IDEMpleado = 16606
  
[Asistencia].[spBuscarVacacionesPendientesEmpleado] @IDEmpleado = 1279,@IDUsuario = 1  
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2019-04-11				Aneudy Abreu	Se sustityó el código anterior para usar el sp [Asistencia].[spBuscarSaldosVacacionesPorAnios]   
										que ya existia.  
2022-01-01				Julio Castillo	Se la pasó el parametro de FechaBaja al sp [Asistencia].[spBuscarSaldosVacacionesPorAnios]
***************************************************************************************************/  
--select * from RH.tblEmpleados where IDEmpleado = 20314  
--select * from RH.tblCatTiposPrestaciones  5613,2
  
CREATE PROCEDURE [Asistencia].[spBuscarVacacionesPendientesEmpleadoFiniquito]-- 5613,2,'2016-01-05','2020-01-19' ,1 
(  
 @IDEmpleado int,  
 @IDTipoPrestacion int = null,  
 @FechaIni Date = null,  
 @FechaFin Date = null,  
 @IDUsuario int    
)  
AS  
BEGIN  
 declare @saldosVacaciones [Asistencia].[dtSaldosDeVacaciones],
  @fechaIniUltimoAño date ,
  @DiasDiferencia int,
  @DiasPendientes decimal(10,2),
  @DiasProporcionalUltimoAnio decimal(10,2),
  @ultimoanio int,
  @DiasTomados int,
  @DiasSaldoAnioPrevio int
  ;  
  
 insert @saldosVacaciones  
 exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=@IDEmpleado,@Proporcional=1,@FechaBaja= @FechaFin,@IDUsuario=@IDUsuario

 select top 1 @fechaIniUltimoAño = FechaIni from @saldosVacaciones 
 ORDER BY Anio desc 

 set @DiasDiferencia = DATEDIFF(day,@fechaIniUltimoAño,@FechaFin)+1

 print @DiasDiferencia

 select top 1 /*@DiasPendientes = Dias  ,*/ @ultimoanio = Anio
 from @saldosVacaciones 
 ORDER BY Anio desc  

 select @DiasPendientes = sum(DiasDisponibles)
 from @saldosVacaciones

 select @DiasTomados =  SUM(Diastomados)
 from @saldosVacaciones
-- where Anio < @ultimoanio


 select @DiasSaldoAnioPrevio =  SUM(Dias)
 from @saldosVacaciones
 --where Anio < @ultimoanio

-- select @DiasSaldoAnioPrevio, @DiasTomados

 --select @DiasProporcionalUltimoAnio = ((@DiasPendientes / 365.0) * @DiasDiferencia) 



 --select @DiasProporcionalUltimoAnio + (ISNULL(@DiasSaldoAnioPrevio,0)-ISNULL(@DiasTomados,0)) as Saldo
 select @DiasPendientes as Saldo




 --DECLARE @VacacionesTomadas int,  
 --  @Antiguedad decimal(18,2),  
     
 --  @VacacionesCompletas int,  
 --  @VacacionesParciales decimal(18,4),  
 --  @Saldo decimal(18,2) = 0  
  
 --Select @VacacionesTomadas = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,'V',@FechaIni,@FechaFin)  
 ----select @VacacionesTomadas as VacacionesTomadas  
  
 --Select @Antiguedad = Cast(DATEDIFF(DAY,@FechaIni,@FechaFin) as decimal)/365.0  
 ----select @Antiguedad  
  
 --Select @VacacionesCompletas = SUM(DiasVacaciones)   
 --from [RH].[tblCatTiposPrestacionesDetalle]  
 --where IDTipoPrestacion = @IDTipoPrestacion  
 -- and Antiguedad <= case when @Antiguedad < 1 then 1 Else @Antiguedad END  
 ----select @VacacionesCompletas as VacacionesCompletas  
  
  
 --Select top 1 @VacacionesParciales = (CAST(DiasVacaciones as decimal)/365) * (365 * (@Antiguedad - CAST(@Antiguedad as int)))  
 --from [RH].[tblCatTiposPrestacionesDetalle]  
 --where IDTipoPrestacion = @IDTipoPrestacion  
 -- and Antiguedad > case when @Antiguedad < 1 then 1 Else @Antiguedad END  
 --ORDER BY Antiguedad ASC  
 ----select @VacacionesParciales as VacacionesParciales  
  
 --Select @Saldo = case when @Antiguedad < 1 then @VacacionesParciales - @VacacionesTomadas Else (@VacacionesCompletas+@VacacionesParciales) - @VacacionesTomadas END  
   
  
 --select @Saldo as Saldo  
END
GO
