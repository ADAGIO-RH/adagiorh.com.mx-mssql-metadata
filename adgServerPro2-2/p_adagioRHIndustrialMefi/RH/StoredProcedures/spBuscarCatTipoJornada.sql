USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RH.spBuscarCatTipoJornada
(
	@TipoJornada varchar(max) = null
)
AS
BEGIN
	SELECT 
		 TJ.IDTipoJornada
		,TJ.Descripcion
		,isnull(TJ.IDSatTipoJornada,0) as IDSatTipoJornada
		,stp.Codigo
		,stp.Descripcion SatTipoJornada
	FROM [RH].[tblCatTipoJornada] TJ
		inner join sat.tblCatTiposJornada stp
			on tj.IDSatTipoJornada = stp.IDTipoJornada 
	WHERE (tj.Descripcion like @TipoJornada+'%') 
		or (@TipoJornada is null)
		
END
GO
