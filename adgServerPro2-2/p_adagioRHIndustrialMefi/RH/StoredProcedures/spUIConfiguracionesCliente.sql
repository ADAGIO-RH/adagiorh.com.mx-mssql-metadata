USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIConfiguracionesCliente](
	@IDCliente int,
	@IDTipoConfiguracionCliente varchar(255),
	@Valor Varchar(255),
	@IDUsuario int
)
AS
BEGIN
DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
    @Mensaje VARCHAR(MAX)


    IF(@IDTipoConfiguracionCliente IN ('SegmentacionPrestacionesVacaciones','VacacionesCaducanEn','FechaIngresoVacaciones') 
        AND NOT EXISTS
        (SELECT * FROM RH.tblConfiguracionesCliente 
            WHERE IDCliente = @IDCliente 
            AND IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente 
            AND Valor = @Valor))
    BEGIN
    PRINT 'CAMBIO VACACIONES'

    set @Mensaje = 'GENERACION DE VACACIONES POR CAMBIO DE CONFIGURACION ' + @IDTipoConfiguracionCliente

    EXEC [Auditoria].[spIAuditoriaVacaciones] 
            @IDUsuario  = @IDUsuario,
            @Tabla = '[Asistencia].[tblSaldoVacacionesEmpleado]',
            @Procedimiento = '[RH].[spUIConfiguracionesCliente]',
            @Accion = 'INSERT-UPDATE',
            @NewData = '',
            @OldData = '',
            @Mensaje = @Mensaje,
            @IDCliente  = @IDCliente

    EXEC [Asistencia].[spSchedulerGeneracionVacaciones] @IDCliente = @IDCliente, @IDUsuario = @IDUsuario
    END

	IF Exists (select * from RH.tblConfiguracionesCliente where IDCliente = @IDCliente and IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente)
	BEGIN
		select @OldJSON = a.JSON from [RH].[tblConfiguracionesCliente] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente
		and IDCliente = @IDCliente

		UPDATE RH.tblConfiguracionesCliente
			set valor = @Valor
		WHERE IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente
			and IDCliente = @IDCliente
		
		select @NewJSON = a.JSON from [RH].[tblConfiguracionesCliente] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente
		and IDCliente = @IDCliente

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblConfiguracionesCliente]','[RH].[spUIConfiguracionesCliente]','UDPATE',@NewJSON,@OldJSON


	END
	ELSE
	BEGIN
		INSERT INTO RH.tblConfiguracionesCliente(IDCliente,IDTipoConfiguracionCliente,Valor)
		VALUES(@IDCliente, @IDTipoConfiguracionCliente,@Valor)

		
		select @NewJSON = a.JSON from [RH].[tblConfiguracionesCliente] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente
		and IDCliente = @IDCliente

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblConfiguracionesCliente]','[RH].[spUIConfiguracionesCliente]','INSERT',@NewJSON,''




	END


	--EXEC [RH].[spBuscarConfiguracionesCliente] @IDCliente = @IDCliente, @IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente

END
GO
