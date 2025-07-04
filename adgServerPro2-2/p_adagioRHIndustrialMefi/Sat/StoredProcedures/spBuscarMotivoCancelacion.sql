USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarMotivoCancelacion]
(
	@MotivoCancelacion Varchar(50) = ''
)
AS
BEGIN
	IF(@MotivoCancelacion = '' or @MotivoCancelacion is null)
	BEGIN
		select 
			IDMotivoCancelacion
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatMotivoCancelacion]
	END
	ELSE
	BEGIN
		select 
			IDMotivoCancelacion
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatMotivoCancelacion]
		where Descripcion like @MotivoCancelacion +'%'
			OR Codigo like @MotivoCancelacion+'%'
	END
END
GO
