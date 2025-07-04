USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Utilerias].[spActualizarFotosUsuariosExistentes]
	@stringArchivos VARCHAR(MAX) = ''
AS
BEGIN

	MERGE [Seguridad].[tblFotoUsuarios]  T
	USING [App].[Split](@stringArchivos,',') S ON T.Cuenta = S.Item
	
	WHEN NOT MATCHED BY TARGET AND EXISTS (SELECT 1 FROM Seguridad.tblUsuarios WHERE Cuenta = S.Item) THEN
	INSERT (Cuenta,IDUsuario) VALUES (S.Item,(select IDUsuario from Seguridad.tblUsuarios where Cuenta = S.Item))

	WHEN NOT MATCHED BY SOURCE 
	THEN 
	DELETE;

END
GO
