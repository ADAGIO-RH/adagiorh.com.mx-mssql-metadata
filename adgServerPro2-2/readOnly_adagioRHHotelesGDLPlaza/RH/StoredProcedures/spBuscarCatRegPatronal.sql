USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatRegPatronal]    
(    
 @IDRegPatronal int = 0    
 ,@IDUsuario int = null  
)    
AS    
BEGIN   
  
     SET FMTONLY OFF;

IF OBJECT_ID('tempdb..#TempRegPatronales') IS NOT NULL  
  DROP TABLE #TempRegPatronales  
  
 select ID   
  Into #TempRegPatronales  
 from Seguridad.tblFiltrosUsuarios  with(nolock) 
 where IDUsuario = @IDUsuario and Filtro = 'RegPatronales'  
  
    
 SELECT     
  RP.IDRegPatronal    
  ,RP.[RegistroPatronal]    
  ,RP.RazonSocial    
  ,RP.ActividadEconomica    
  ,isnull(RP.IDClaseRiesgo,0) as IDClaseRiesgo    
  ,'['+CR.Codigo+'] '+CR.Descripcion AS ClaseRiesgo    
  ,isnull(RP.IDCodigoPostal,0) as IDCodigoPostal    
  ,CP.CodigoPostal    
  ,isnull(RP.IDEstado,0) as IDEstado    
  ,'['+E.Codigo+'] '+E.NombreEstado as Estado    
  ,isnull(RP.IDMunicipio,0) as IDMunicipio    
  ,'['+M.Codigo+'] '+M.Descripcion as Municipio    
  ,isnull(RP.IDColonia,0) as IDColonia    
  ,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia    
  ,isnull(RP.IDPais,0) as IDPais    
  ,'['+P.Codigo+'] '+P.Descripcion as Pais    
  ,RP.Calle    
  ,RP.Exterior    
  ,RP.Interior    
  ,RP.Telefono    
  ,isnull(RP.ConvenioSubsidios,cast(0 as bit)) as ConvenioSubsidios    
  ,RP.DelegacionIMSS    
  ,RP.SubDelegacionIMSS    
  ,RP.FechaAfiliacion    
  ,RP.RepresentanteLegal    
  ,RP.OcupacionRepLegal    
 FROM [RH].[tblCatRegPatronal] RP  with(nolock)   
  LEFT join Sat.tblCatCodigosPostales CP   with(nolock)  
   on RP.IDCodigoPostal = CP.IDCodigoPostal    
  LEFT join Sat.tblCatPaises P   with(nolock)  
   on RP.IDPais = p.IDPais    
  LEFT join Sat.tblCatEstados E   with(nolock)  
   on RP.IDEstado = E.IDEstado    
  LEFT join Sat.tblCatMunicipios M   with(nolock)  
   on RP.IDMunicipio = m.IDMunicipio    
  LEFT join Sat.tblCatColonias CL   with(nolock)  
   on RP.IDColonia = CL.IDColonia    
  LEFT join IMSS.tblCatClaseRiesgo CR   with(nolock)  
   on CR.IDClaseRiesgo = RP.IDClaseRiesgo    
 WHERE ((RP.IDRegPatronal = @IDRegPatronal) or (@IDRegPatronal is null) or (@IDRegPatronal = 0))    
  and (RP.IDRegPatronal in  ( select ID from #TempRegPatronales)  
 OR Not Exists(select ID from #TempRegPatronales))  
 ORDER BY RP.[RazonSocial] ASC    
      
END
GO
