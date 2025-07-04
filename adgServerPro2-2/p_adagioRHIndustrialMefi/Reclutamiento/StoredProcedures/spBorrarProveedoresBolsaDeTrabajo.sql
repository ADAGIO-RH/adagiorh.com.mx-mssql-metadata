USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-06
-- Description:	Eliminar Proveedor de Bolsa de Trabajo
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBorrarProveedoresBolsaDeTrabajo]
	(
	@IDProveedorBolsaDeTrabajo int = 0
	,@IDUsuario int =0 
	)
AS
BEGIN

SELECT        IDProveedorBolsaDeTrabajo, Nombre, StatusProveedor
FROM            Reclutamiento.tblProveedoresBolsaDeTrabajo
WHERE        (IDProveedorBolsaDeTrabajo = @IDProveedorBolsaDeTrabajo) OR
                         (ISNULL(@IDProveedorBolsaDeTrabajo, 0) = 0)

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Reclutamiento].[tblProveedoresBolsaDeTrabajo] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDProveedorBolsaDeTrabajo = @IDProveedorBolsaDeTrabajo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblProveedoresBolsaDeTrabajo]','[Reclutamiento].[Reclutamiento].[spBorrarProveedoresBolsaDeTrabajo]','DELETE','',@OldJSON
		
	IF(@IDProveedorBolsaDeTrabajo <> 0)
	BEGIN
		delete from [Reclutamiento].[tblProveedoresBolsaDeTrabajo]
		where IDProveedorBolsaDeTrabajo = @IDProveedorBolsaDeTrabajo
	END;
END
GO
