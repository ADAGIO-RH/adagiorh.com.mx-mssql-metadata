USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatSucursales]      
(      
 @IDSucursal int = null    
 ,@IDUsuario int = null    
)      
AS      
BEGIN     
  SET FMTONLY OFF;
  
IF OBJECT_ID('tempdb..#TempSucursales') IS NOT NULL  
  DROP TABLE #TempSucursales  
  
 select ID   
  Into #TempSucursales  
 from Seguridad.tblFiltrosUsuarios   
 where IDUsuario = @IDUsuario and Filtro = 'Sucursales'  
  
   
 SELECT       
  S.IDSucursal      
  ,S.Codigo       
  ,S.Descripcion       
  ,S.CuentaContable      
  ,isnull(S.IDCodigoPostal,0) as IDCodigoPostal      
  ,CP.CodigoPostal      
  ,isnull(S.IDEstado,0) as IDEstado      
  ,'['+E.Codigo+'] '+E.NombreEstado as Estado      
  ,isnull(S.IDMunicipio,0) as IDMunicipio      
  ,'['+M.Codigo+'] '+M.Descripcion as Municipio      
  ,isnull(S.IDColonia,0) as IDColonia      
  ,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia      
  ,isnull(S.IDPais,0) as IDPais      
  ,'['+P.Codigo+'] '+P.Descripcion as Pais      
  ,S.Calle      
  ,S.Exterior      
  ,S.Interior      
  ,S.Telefono    
  ,S.Responsable      
  ,S.Email      
  ,S.ClaveEstablecimiento      
  ,isnull(S.IDEstadoSTPS,0) as IDEstadoSTPS      
  ,'['+STPSEstados.Codigo+'] '+STPSEstados.Descripcion as EstadoSTPS      
  ,isnull(S.IDMunicipioSTPS,0) as IDMunicipioSTPS      
  ,'['+STPSMunicipios.Codigo+'] '+STPSMunicipios.Descripcion as MunicipioSTPS      
        
 FROM [RH].[tblCatSucursales] S      
  left join Sat.tblCatCodigosPostales CP      
   on S.IDCodigoPostal = CP.IDCodigoPostal      
  left join Sat.tblCatPaises P      
   on S.IDPais = p.IDPais      
  left join Sat.tblCatEstados E      
   on S.IDEstado = E.IDEstado      
  left join Sat.tblCatMunicipios M      
   on S.IDMunicipio = m.IDMunicipio      
  left join Sat.tblCatColonias CL      
   on S.IDColonia = CL.IDColonia      
  Left Join STPS.tblCatEstados STPSEstados      
   on S.IDEstadoSTPS = STPSEstados.IDEstado      
  Left Join STPS.tblCatMunicipios STPSMunicipios      
   on S.IDMunicipioSTPS = STPSMunicipios.IDMunicipio      
 WHERE ((S.IDSucursal = @IDSucursal) OR (@IDSucursal is null))      
 and (S.IDSucursal in  ( select ID from #TempSucursales)  
 OR Not Exists(select ID from #TempSucursales))  
 ORDER BY S.Descripcion ASC      
        
END
GO
