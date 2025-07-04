USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarOrigenesRecursos]
(
	@OrigenRecurso Varchar(50) = ''
)
AS
BEGIN
	IF(@OrigenRecurso = '' or @OrigenRecurso is null)
	BEGIN
		select 
			IDOrigenRecurso
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatOrigenesRecursos]
	END
	ELSE
	BEGIN
		select 
			IDOrigenRecurso
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatOrigenesRecursos]
		where Descripcion like @OrigenRecurso +'%'
			OR Codigo like @OrigenRecurso+'%'
	END
END
GO
