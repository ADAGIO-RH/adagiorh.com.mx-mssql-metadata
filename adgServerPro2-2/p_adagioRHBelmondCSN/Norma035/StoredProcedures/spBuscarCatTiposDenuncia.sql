USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma035].[spBuscarCatTiposDenuncia]
AS
BEGIN
	
    SET FMTONLY OFF; 



    /****** Script for SelectTopNRows command from SSMS  ******/
SELECT [IDTipoDenuncia]
      ,upper([Descripcion]) as Descripcion
      ,[PermitirAnonimo]
      ,[UltimaActualizacion]
  FROM [d_adagioRH].[Norma035].[tblCatTiposDenuncia]
  where [Estatus] = 1
		
END
GO
