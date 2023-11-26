USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatOrganigramas]
(
	@IDOrganigrama int = 0	
)
AS
BEGIN
    select 
    [IDOrganigrama],
    [Filtro],
    [IDReferencia] 
    From rh.tblCatOrganigramas
END
GO
