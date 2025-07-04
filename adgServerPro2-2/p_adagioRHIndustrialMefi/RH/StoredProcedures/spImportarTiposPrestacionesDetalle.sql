USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [RH].[spImportarTiposPrestacionesDetalle](
    @IDTipoPrestacion int
   ,@detalle [RH].[dtTiposPrestacionesDetalle] READONLY
   ,@IDUsuario int  
  ) as
begin

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestacionesDetalle]','[RH].[spImportarTiposPrestacionesDetalle]','DELETE - IMPORT','',''

    DECLARE @Sum1 INT, @Sum2 INT

    SELECT @Sum1 = SUM(DiasVacaciones) 
    FROM RH.tblCatTiposPrestacionesDetalle 
    WHERE IDTipoPrestacion = @IDTipoPrestacion

    SELECT @Sum2 = SUM(DiasVacaciones) 
    FROM @detalle


    delete from [RH].[tblCatTiposPrestacionesDetalle]
    where IDTipoPrestacion=@IDTipoPrestacion

    insert into [RH].[tblCatTiposPrestacionesDetalle](IDTipoPrestacion,Antiguedad,DiasAguinaldo,DiasVacaciones,PrimaVacacional,PorcentajeExtra,DiasExtras)
    select @IDTipoPrestacion,Antiguedad,DiasAguinaldo,DiasVacaciones,PrimaVacacional,PorcentajeExtra,DiasExtra
    from @detalle
    where Antiguedad is not null

    IF (@Sum1 <> @Sum2) 
    BEGIN
        PRINT 'CAMBIO'

        EXEC [Auditoria].[spIAuditoriaVacaciones] 
            @IDUsuario  = @IDUsuario,
            @Tabla = '[Asistencia].[tblSaldoVacacionesEmpleado]',
            @Procedimiento = '[RH].[spImportarTiposPrestacionesDetalle]',
            @Accion = 'DELETE - IMPORT',
            @NewData = '',
            @OldData = '',
            @Mensaje = 'GENERACION DE VACACIONES POR CAMBIO DE DETALLE DE VACACIONES DE PRESTACION',
            @IDTipoPrestacion  = @IDTipoPrestacion

        EXEC [Asistencia].[spSchedulerGeneracionVacaciones] @IDTipoPrestacion = @IDTipoPrestacion, @IDUsuario = @IDUsuario
    END
END;
GO
