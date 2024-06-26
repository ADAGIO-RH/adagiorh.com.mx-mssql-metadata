USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarPorcentajesPago]    
(    
 @IDPorcentajesPago int = null    
)    
AS    
BEGIN    
 Select     
  IDPorcentajesPago    
  ,Fecha    
  ,CuotaFija							= case when CuotaFija <> 0 THEN CuotaFija * 100 else 0 END    
  ,ExcedentePatronal					= case when ExcedentePatronal <> 0 THEN ExcedentePatronal * 100 else 0 END 
  ,ExcedenteObrera      				= case when ExcedenteObrera <> 0 THEN ExcedenteObrera * 100 else 0 END 
  ,PrestacionesDineroPatronal      		= case when PrestacionesDineroPatronal <> 0 THEN PrestacionesDineroPatronal * 100 else 0 END 
  ,PrestacionesDineroObrera      		= case when PrestacionesDineroObrera <> 0 THEN PrestacionesDineroObrera * 100 else 0 END 
  ,GMPensionadosPatronal      			= case when GMPensionadosPatronal <> 0 THEN GMPensionadosPatronal * 100 else 0 END 
  ,GMPensionadosObrera      			= case when GMPensionadosObrera <> 0 THEN GMPensionadosObrera * 100 else 0 END 
  ,RiesgosTrabajo      					= case when RiesgosTrabajo <> 0 THEN RiesgosTrabajo * 100 else 0 END 
  ,InvalidezVidaPatronal      			= case when InvalidezVidaPatronal <> 0 THEN InvalidezVidaPatronal * 100 else 0 END 
  ,InvalidezVidaObrera      			= case when InvalidezVidaObrera <> 0 THEN InvalidezVidaObrera * 100 else 0 END 
  ,GuarderiasPrestacionesSociales      	= case when GuarderiasPrestacionesSociales <> 0 THEN GuarderiasPrestacionesSociales * 100 else 0 END 
  ,CesantiaVejezPatron      			= case when CesantiaVejezPatron <> 0 THEN CesantiaVejezPatron * 100 else 0 END 
  ,SeguroRetiro      					= case when SeguroRetiro <> 0 THEN SeguroRetiro * 100 else 0 END 
  ,Infonavit      						= case when Infonavit <> 0 THEN Infonavit * 100 else 0 END 
  ,CesantiaVejezObrera      			= case when CesantiaVejezObrera <> 0 THEN CesantiaVejezObrera * 100 else 0 END 
  ,ReservaPensionado      				= case when ReservaPensionado <> 0 THEN ReservaPensionado * 100 else 0 END 
  ,CuotaProporcionalObrera      		= case when CuotaProporcionalObrera <> 0 THEN CuotaProporcionalObrera * 100 else 0 END  
 From IMSS.tblCatPorcentajesPago    
 WHERE IDPorcentajesPago = @IDPorcentajesPago OR @IDPorcentajesPago is null    
  ORDER BY Fecha DESC  
  
END
GO
