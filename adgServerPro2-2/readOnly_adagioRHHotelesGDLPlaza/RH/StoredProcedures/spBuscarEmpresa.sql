USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarEmpresa]    
(    
 @IDEmpresa int = null    
 ,@IDUsuario int = null  
)    
AS    
BEGIN    
   SET FMTONLY OFF;
  
IF OBJECT_ID('tempdb..#TempEmpresa') IS NOT NULL  
  DROP TABLE #TempEmpresa  
  
 select ID   
  Into #TempEmpresa  
 from Seguridad.tblFiltrosUsuarios  with(nolock) 
 where IDUsuario = @IDUsuario and Filtro = 'RazonesSociales'  
  
  
  
 SELECT     
  C.IdEmpresa    
  ,C.RFC    
  ,C.NombreComercial    
  ,C.RegFonacot    
  ,C.RegInfonavit    
  ,C.RegSIEM    
  ,C.RegEstatal    
  ,isnull(C.IDCodigoPostal,0) as IDCodigoPostal    
  ,CP.CodigoPostal    
  ,isnull(C.IDEstado,0) as IDEstado    
  ,'['+E.Codigo+'] '+E.NombreEstado as Estado    
  ,isnull(C.IDMunicipio,0) as IDMunicipio    
  ,'['+M.Codigo+'] '+M.Descripcion as Municipio    
  ,isnull(C.IDColonia,0) as IDColonia    
  ,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia    
  ,isnull(C.IDPais,0) as IDPais    
  ,'['+P.Codigo+'] '+P.Descripcion as Pais    
  ,C.Calle    
  ,C.Exterior    
  ,C.Interior    
  ,ISNULL(C.IDRegimenFiscal,0) AS IDRegimenFiscal    
  ,RF.Descripcion as RegimenFiscal    
  ,ISNULL(C.IDOrigenRecurso,0) AS IDOrigenRecurso    
  ,OrigenRecurso.Descripcion as OrigenRecurso    
    
 FROM RH.[tblEmpresa] C with(nolock)    
  LEFT join Sat.tblCatCodigosPostales CP  with(nolock)   
   on c.IDCodigoPostal = CP.IDCodigoPostal    
  LEFT join Sat.tblCatPaises P    with(nolock) 
   on c.IDPais = p.IDPais    
  LEFT join Sat.tblCatEstados E   with(nolock)  
   on C.IDEstado = E.IDEstado    
  LEFT join Sat.tblCatMunicipios M   with(nolock)  
   on c.IDMunicipio = m.IDMunicipio    
  LEFT join Sat.tblCatColonias CL    with(nolock) 
   on c.IDColonia = CL.IDColonia    
  Left Join Sat.tblCatRegimenesFiscales RF  with(nolock)   
   on C.IDRegimenFiscal = RF.IDRegimenFiscal    
  Left Join Sat.tblCatOrigenesRecursos OrigenRecurso with(nolock)     
   on OrigenRecurso.IDOrigenRecurso = C.IDOrigenRecurso    
 WHERE (c.IDEmpresa = @IDEmpresa) OR (@IDEmpresa IS NULL)    
   and (c.IdEmpresa in  ( select ID from #TempEmpresa)  
 OR Not Exists(select ID from #TempEmpresa))  
  ORDER BY C.NombreComercial ASC    
END
GO
