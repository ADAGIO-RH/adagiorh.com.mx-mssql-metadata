USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTiposDeduccionesPrestaciones]
as
select IDTipoDeduccion as ID, Codigo, Descripcion,2 as Tipo
from Sat.tblCatTiposDeducciones
UNION
select IDTipoPercepcion as ID, Codigo, Descripcion,1 as Tipo
from Sat.tblCatTiposPercepciones
UNION
select IDTipoOtroPago as ID, Codigo, Descripcion,4 as Tipo
from Sat.tblCatTiposOtrosPagos
UNION
select IDTipoDeduccion as ID, Codigo, Descripcion,8 as Tipo
from Sat.tblCatTiposDeducciones
UNION
select IDTipoPercepcion as ID, Codigo, Descripcion,7 as Tipo
from Sat.tblCatTiposPercepciones
UNION
select IDTipoOtroPago as ID, Codigo, Descripcion,10 as Tipo
from Sat.tblCatTiposOtrosPagos
GO
