USE [p_adagioRHOwenSLP]
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
  
CREATE PROCEDURE [Asistencia].[spBuscarVacacionesPendientesEmpleadoFiniquito] --30518,3,'2024-10-31','2025-01-27' ,1 
(  
 @IDEmpleado int,  
 @IDTipoPrestacion int = null,  
 @FechaIni Date = null,  
 @FechaFin Date = null,  
 @IDUsuario int,
 @IDMovimientoBaja int = 0    
)  
AS  
BEGIN  
 declare @saldosVacaciones [Asistencia].[dtSaldosDeVacaciones],
  @FechaIniUltimoAño date ,
  @DiasPendientes decimal(10,2),
  @ultimoanio int,
  @DiasGeneradosUltimoAño decimal(10,2)
 


IF((SELECT COUNT(*) 
                        FROM Asistencia.tblIncidenciaEmpleado ie WITH(NOLOCK) 
                        INNER JOIN Asistencia.tblSaldoVacacionesEmpleado sve ON sve.IDIncidenciaEmpleado = ie.IDIncidenciaEmpleado
                        WHERE sve.IDEmpleado = @IDEmpleado AND IDIncidencia = 'V' AND Fecha >= @FechaFin) > 0 )
BEGIN

    DECLARE @MensajeFiniquito VARCHAR(max) = 'ERROR VACACIONES: El colaborador tiene vacaciones autorizadas posteriores a la fecha de baja'
    RAISERROR(@MensajeFiniquito, 16,1)
    RETURN

END

    insert @saldosVacaciones  
    exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado= @IDEmpleado,@Proporcional=1,@FechaBaja= @FechaFin,@IDUsuario=@IDUsuario,@IDMovimientoBaja = @IDMovimientoBaja 

    select @DiasPendientes = sum(DiasDisponibles)
    from @saldosVacaciones

    IF EXISTS(Select top 1 1 from app.tblConfiguracionesGenerales CG where IDConfiguracion = 'RefactorizacionVacaciones' and Valor = 1)
    BEGIN

        select top 1 @ultimoanio = Anio
        from @saldosVacaciones 
        ORDER BY Anio desc  

        Select Top 1 @DiasGeneradosUltimoAño = DiasGenerados from @saldosVacaciones order by Anio DESC

        DECLARE 
            @DiasUltimoAnio int,
            @Factor decimal(10,2), 
            @DiasPendientesUltimoAnio int

        SELECT @DiasUltimoAnio = DiasVacaciones 
            FROM [RH].[tblCatTiposPrestacionesDetalle] 
            WHERE IDTipoPrestacion = @IDTipoPrestacion 
            and Antiguedad = (
                Select top 1 
                    CASE WHEN @FechaFin > FechaFin 
                        THEN Anio + 1 
                        ELSE anio 
                    END 
                from @saldosVacaciones 
                order by anio desc
            )


        SELECT TOP 1 @Factor = CAST((@DiasUltimoAnio * DATEDIFF(DAY, 
            Case when @FechaFin > fechafin 
                then DATEADD(YEAR,1,FechaIni)
                ELSE FechaIni 
            END, @FechaFin)) AS decimal(10,2)) / 365.2425 
        from @saldosVacaciones 
        order by Anio DESC

        SELECT CASE 
        WHEN @DiasUltimoAnio > (Select Dias from @saldosVacaciones where Anio = @ultimoanio) THEN @DiasPendientes + (@Factor - Floor(@Factor))
        WHEN @DiasGeneradosUltimoAño <= @Factor THEN @DiasPendientes + (@Factor - Floor(@Factor))  
        ELSE @DiasPendientes  END as Saldo

    END
    ELSE
    BEGIN

    Select @DiasPendientes as Saldo    
    
    END

END
GO
