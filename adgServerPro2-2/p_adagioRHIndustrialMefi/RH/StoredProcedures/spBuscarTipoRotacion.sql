USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  RH.spBuscarTipoRotacion
AS
BEGIN

Select 1 as IDTipoRotacion,
      'NUEVOS INGRESOS' as TipoRotacion
union
Select 2 as IDTipoRotacion,
      'REINGRESOS' as TipoRotacion
union
Select 3 as IDTipoRotacion,
      'NUEVOS INGRESOS Y REINGRESOS' as TipoRotacion
union
Select 4 as IDTipoRotacion,
      'SOLO BAJAS' as TipoRotacion
union
Select 5 as IDTipoRotacion,
      'NUEVOS INGRESOS, REINGRESOS Y BAJAS' as TipoRotacion

END
GO
