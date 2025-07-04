USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [Saludoc].[spIUProcesosEncuestasCliente](
	@IDProcesoEncuesta int = 0,
	@IDCliente int,
	@FechaInicio Date,
	@FechaFin Date,
	@IDUsuario int,
	@Factor Decimal(18,4)
)
AS
BEGIN
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDProcesoEncuesta = 0 OR @IDProcesoEncuesta Is null)
	BEGIN

		INSERT INTO [Saludoc].[tblProcesosEncuestasCliente]
				   (
					IDCliente
					,IDUsuario
					,FechaInicio
					,FechaFin
					,Factor
				   )
			 VALUES
				   (
				     @IDCliente
					,@IDUsuario
					,@FechaInicio
					,@FechaFin
					,@Factor
				   )

		Set @IDProcesoEncuesta = @@IDENTITY

		select @NewJSON = (SELECT 
									PEC.IDProcesoEncuesta
									,PEC.IDCliente
									,C.NombreComercial
									,PEC.IDUsuario
									,PEC.FechaInicio
									,PEC.FechaFin
                            FROM  Saludoc.tblProcesosEncuestasCliente PEC WITH(NOLOCK)
								inner join RH.tblcatClientes C WITH(NOLOCK)
									on PEC.IDCliente = c.IDCliente
                            WHERE PEC.IDProcesoEncuesta = @IDProcesoEncuesta FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Saludoc].[tblProcesosEncuestasCliente]','[Saludoc].[spIUProcesosEncuestasCliente]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN


		select @OldJSON = (SELECT 
									PEC.IDProcesoEncuesta
									,PEC.IDCliente
									,C.NombreComercial
									,PEC.IDUsuario
									,PEC.FechaInicio
									,PEC.FechaFin
                            FROM  Saludoc.tblProcesosEncuestasCliente PEC WITH(NOLOCK)
								inner join RH.tblcatClientes C WITH(NOLOCK)
									on PEC.IDCliente = c.IDCliente
                            WHERE PEC.IDProcesoEncuesta = @IDProcesoEncuesta FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		UPDATE [Saludoc].[tblProcesosEncuestasCliente]
		   SET IDCliente		= @IDCliente
				,IDUsuario		= @IDUsuario
				,FechaInicio	= @FechaInicio
				,FechaFin		= @FechaFin
				,Factor			= @Factor
		 WHERE IDProcesoEncuesta = @IDProcesoEncuesta



		select @NewJSON = (SELECT 
									PEC.IDProcesoEncuesta
									,PEC.IDCliente
									,C.NombreComercial
									,PEC.IDUsuario
									,PEC.FechaInicio
									,PEC.FechaFin
                            FROM  Saludoc.tblProcesosEncuestasCliente PEC WITH(NOLOCK)
								inner join RH.tblcatClientes C WITH(NOLOCK)
									on PEC.IDCliente = c.IDCliente
                            WHERE PEC.IDProcesoEncuesta = @IDProcesoEncuesta FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Saludoc].[tblProcesosEncuestasCliente]','[Saludoc].[spIUProcesosEncuestasCliente]','UPDATE',@NewJSON,@OldJSON
	END

END
GO
