USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA BORRAR LOS LECTORES
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBorrarLectores] 
(
	 @IDLector int,
	 @IDUsuario int
)
AS
BEGIN
    if (EXISTS (SELECT TOP 1 1 FROM [Asistencia].[tblLectoresEmpleados] WHERE IDLector = @IDLector) )
    begin
	   raiserror('No se puede eliminar un lector que tenga registros de usuarios asociados.',11,0)
	   return;
    end;

     if (EXISTS (SELECT TOP 1 1 FROM [Asistencia].[tblChecadas] where IDLector = @IDLector) )
    begin
	   raiserror('No se puede eliminar un lector que tenga registros de checadas asociados.',11,0)
	   return;
    end;

	DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

	EXEC Asistencia.spBuscarLectores @IDLector = @IDLector, @IDUsuario = @IDUsuario

	select @OldJSON =(SELECT Lector
                            ,CodigoLector
                            ,PasswordLector
                            ,IDTipoLector
                            ,IDZonaHoraria
                            ,[IP]
                            ,Puerto
                            ,IDCliente
                            ,EsComedor
                            ,Comida
                            ,Master
                            ,NumeroSerial
                            ,Configuracion
                            ,AsignarTodosLosColaboradores
                            FROM  [Asistencia].[tblLectores]
                            WHERE IDLector = @IDLector FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)   
		
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectores]','[Asistencia].[spBorrarLectores]','DELETE','',@OldJSON

	BEGIN TRY  
		Delete Asistencia.tblLectores
		where IDLector = @IDLector
	END TRY  
	BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END CATCH ;

END
GO
