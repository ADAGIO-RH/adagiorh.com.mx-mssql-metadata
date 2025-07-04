USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarRiesgosPuesto]
(
	@RiesgoPuesto Varchar(50) = ''
)
AS
BEGIN
	IF(@RiesgoPuesto = '' or @RiesgoPuesto is null)
	BEGIN
		select 
			IDRiesgoPuesto
			,UPPER(Codigo)AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatRiesgosPuesto]
	END
	ELSE
	BEGIN
		select 
			IDRiesgoPuesto
			,UPPER(Codigo)AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatRiesgosPuesto]
		where Descripcion like @RiesgoPuesto +'%'
			OR Codigo like @RiesgoPuesto+'%'
	END
END
GO
