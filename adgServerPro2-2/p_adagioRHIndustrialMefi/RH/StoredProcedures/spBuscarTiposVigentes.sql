USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RH.spBuscarTiposVigentes
AS
BEGIN
	Select 1 as IDTipoVigente,
      'VIGENTES' as TipoVigente
	union
	Select 2 as IDTipoVigente,
		  'NO VIGENTES' as TipoVigente
	union
	Select 3 as IDTipoVigente,
		  'AMBOS' as TipoVigente
END
GO
