USE [p_adagioRHLya]
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
create proc [Norma035].[spBuscarSecionesEncuesta](
	 @IDEncuesta int
) as


declare @TipoEncuesta int;

select 
    @TipoEncuesta = te.IDTipoEncuesta
from
    [Norma035].[tblEncuestas] te
	where te.IDEncuesta = @IDEncuesta


	SELECT [IDSeccion]
      ,[IDTipoEncuesta]
      ,[Descripción]
      ,[EsPregunta]
      ,[Estatus]
      ,[UltimaActualizacion]
  FROM [Norma035].[tblCatSeccion]
  where [IDTipoEncuesta] = @TipoEncuesta
GO
