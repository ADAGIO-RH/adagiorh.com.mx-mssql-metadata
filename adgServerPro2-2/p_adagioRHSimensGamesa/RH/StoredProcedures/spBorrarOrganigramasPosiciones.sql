USE [p_adagioRHSimensGamesa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarOrganigramasPosiciones] 
(
	@IDOrganigramaPosicion int,
    @IDUsuario int
)
AS
BEGIN
    DELETE FROM [RH].[tblOrganigramasPosiciones]
      WHERE  IDOrganigramaPosicion = @IDOrganigramaPosicion
END
GO
