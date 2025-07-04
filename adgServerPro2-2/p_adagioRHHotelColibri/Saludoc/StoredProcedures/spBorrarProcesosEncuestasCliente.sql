USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Saludoc].[spBorrarProcesosEncuestasCliente]
(
	@IDProcesoEncuesta int,
	@IDUsuario int
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

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

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Saludoc].[tblProcesosEncuestasCliente]','[Saludoc].[spBorrarProcesosEncuestasCliente]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
			DELETE [Saludoc].tblProcesosEncuestasClienteCuestionariosDetalle
			WHERE IDProcesoEncuesta = @IDProcesoEncuesta
		  
			DELETE [Saludoc].[tblProcesosEncuestasCliente]
			WHERE IDProcesoEncuesta = @IDProcesoEncuesta

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
