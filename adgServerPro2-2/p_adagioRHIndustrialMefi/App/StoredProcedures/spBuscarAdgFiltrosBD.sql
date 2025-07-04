USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [App].[spBuscarAdgFiltrosBD]
	-- Add the parameters for the stored procedure here
    @IDUsuario int=null	
AS
BEGIN
	
    SELECT dg.IsActive,
        dg.Autobind,
        dg.IsRequired,
        dg.LabelText [LabelText],
        dg.NombreParametro,
        dg.NombreVarJS,
        dg.MsjError,
        dg.Show ,
        dg.VisibleAutoBind,
        dg.VisibleLabelText,
        dg.IDTipoComponente,
        dg.IDAdgFiltro from App.tblAdgFiltros AS dg
        order by dg.Orden
END
GO
