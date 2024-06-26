USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Catálogo de Brigadas>
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

CREATE PROCEDURE [RH].[spBorrarCatBrigadas]
(
	@IDBrigada int,
	@IDUsuario int
)
AS
BEGIN
		SELECT IDBrigada,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDBrigada)as ROWNUMBER
	FROM RH.tblCatBrigadas
	Where IDBrigada = @IDBrigada

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatBrigadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBrigada = @IDBrigada

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBrigadas]','[RH].[spBorrarCatBrigadas]','DELETE','',@OldJSON


	DELETE RH.tblCatBrigadas
	Where IDBrigada = @IDBrigada
END
GO
