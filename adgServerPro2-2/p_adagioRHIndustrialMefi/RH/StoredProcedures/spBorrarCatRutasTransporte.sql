USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Catálogo de Rutas de Transporte>
** Autor			: <Jose Rafael Roman Gil>
** Email			: <jose.roman@adagio.com.mx>
** FechaCreacion	: <08/06/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [RH].[spBorrarCatRutasTransporte]
(
	@IDRuta int,
	@IDUsuario int
)
AS
BEGIN
		SELECT IDRuta,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDRuta)as ROWNUMBER
	FROM RH.tblCatRutasTransporte
	Where IDRuta = @IDRuta

			DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatRutasTransporte] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRuta = @IDRuta

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRutasTransporte]','[RH].[spBorrarCatRutasTransporte]','DELETE','',@OldJSON


	DELETE RH.tblCatRutasTransporte
	Where IDRuta = @IDRuta
END
GO
