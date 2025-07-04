USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE RH.spBuscarHistorialPrimaRiesgo  
(  
 @IDRegPatronal int  
)  
AS  
BEGIN  
 SELECT   
  IDHistorialPrimaRiesgo  
  ,IDRegPatronal  
  ,Anio  
  ,Mes  
  ,case when Prima <> 0 THEN Prima * 100 else 0 END  as Prima  
 FROM RH.tblHistorialPrimaRiesgo  
 WHERE IDRegPatronal = @IDRegPatronal  
 ORDER BY Anio,Mes  
  
END
GO
