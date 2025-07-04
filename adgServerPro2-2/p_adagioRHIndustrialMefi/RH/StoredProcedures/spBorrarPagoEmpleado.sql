USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Procedimiento para Borrar el historial de metodos de pago de un Colaborador
** Autor			: Jose Rafael Roman Gil
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 01/01/2018
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto			¿Qué cambió?
2018-05-07		JOSE RAFAEL ROMAN GIL	Se agrega Usuario como Parametro
2018-07-06		Jose Roman				Se agrega Procedure para proceso de Sincronizacion
***************************************************************************************************/

CREATE PROCEDURE [RH].[spBorrarPagoEmpleado]
(
	@IDPagoEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	
	declare @IDEmpleado int = 0;

	select @IDEmpleado = IDEmpleado from RH.tblPagoEmpleado 
	where IDPagoEmpleado = @IDPagoEmpleado

	  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblPagoEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDPagoEmpleado = @IDPagoEmpleado
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblPagoEmpleado]','[RH].[spBorrarPagoEmpleado]','DELETE','',@OldJSON



	DELETE RH.tblPagoEmpleado
	WHERE  IDPagoEmpleado = @IDPagoEmpleado
	
	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
	
END
GO
