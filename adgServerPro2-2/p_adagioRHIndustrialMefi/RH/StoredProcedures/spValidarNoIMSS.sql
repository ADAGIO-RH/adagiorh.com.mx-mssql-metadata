USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RH.spValidarNoIMSS
(
	@IDUsuario int,
	@IMSS Varchar(20)
)
AS
BEGIN
	IF EXISTS(Select 1 from RH.tblEmpleados where IMSS = @IMSS)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario,'0000005'
		RETURN;
	END
END
GO
